import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/catalog_domain.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> insertSeries() async {
    final now = DateTime.now();
    await db.into(db.catalogItems).insert(CatalogItemsCompanion.insert(
          id: 'item-1',
          domain: CatalogDomain.media,
          title: 'Breaking Bad',
          status: WatchStatus.watching,
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.mediaItems).insert(MediaItemsCompanion.insert(
          itemId: 'item-1',
          mediaType: MediaType.movie,
          format: MediaFormat.episodic,
          originalTitle: const Value('Breaking Bad'),
        ));
  }

  test('schema creates, insert + 1:1 join works', () async {
    await insertSeries();
    final core = await db.select(db.catalogItems).get();
    final media = await db.select(db.mediaItems).get();
    expect(core, hasLength(1));
    expect(media, hasLength(1));
    expect(core.single.status, WatchStatus.watching);
    expect(media.single.mediaType, MediaType.movie);
  });

  test('FTS5 trigger indexes title + original_title, search joins by UUID',
      () async {
    await insertSeries();
    final hits = await db
        .customSelect(
          "SELECT c.id AS id FROM catalog_fts f "
          'JOIN catalog_items c ON c.id = f.item_id '
          "WHERE catalog_fts MATCH 'break*' AND c.deleted_at IS NULL",
        )
        .get();
    expect(hits.map((r) => r.read<String>('id')), ['item-1']);
  });

  test('foreign key is enforced (media without parent fails)', () async {
    await expectLater(
      db.into(db.mediaItems).insert(MediaItemsCompanion.insert(
            itemId: 'ghost',
            mediaType: MediaType.movie,
            format: MediaFormat.single,
          )),
      throwsA(isA<SqliteException>()),
    );
  });

  test('checkIntegrity: здоровая БД возвращает true', () async {
    expect(await db.checkIntegrity(), isTrue);
  });

  test('checkIntegrity: битый файл БД возвращает false', () async {
    final dir = Directory.systemTemp.createTempSync('kiseki_corrupt_');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });
    // Не SQLite-заголовок → quick_check/открытие падает → повреждение.
    final f = File(p.join(dir.path, 'broken.sqlite'))
      ..writeAsBytesSync(List.filled(2048, 0x42));
    final broken = AppDatabase(NativeDatabase(f));
    expect(await broken.checkIntegrity(), isFalse);
    try {
      await broken.close();
    } catch (_) {/* битая БД может не закрыться чисто */}
  });

  test('CHECK: movie/single cannot carry season fields', () async {
    final now = DateTime.now();
    await db.into(db.catalogItems).insert(CatalogItemsCompanion.insert(
          id: 'm1',
          domain: CatalogDomain.media,
          title: 'Some Film',
          status: WatchStatus.completed,
          createdAt: now,
          updatedAt: now,
        ));
    await expectLater(
      db.into(db.mediaItems).insert(MediaItemsCompanion.insert(
            itemId: 'm1',
            mediaType: MediaType.movie,
            format: MediaFormat.single,
            currentEpisode: const Value(5),
            currentSeason: const Value(1),
          )),
      throwsA(isA<SqliteException>()),
    );
  });

  test('миграция v1→v4: series→movie + vape_items + damages_hardware', () async {
    final dir = Directory.systemTemp.createTempSync('kiseki_migrate_');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });
    final file = File(p.join(dir.path, 'v1.sqlite'));

    // Поднимаем БД (onCreate ставит текущую user_version), кладём legacy-строку
    // media_type='series' напрямую (минуя enum-конвертер) и откатываем
    // user_version к 1 — имитируем БД старой версии.
    final v1 = AppDatabase(NativeDatabase(file));
    await v1.customStatement(
      "INSERT INTO catalog_items (id, domain, title, status, is_favorite, "
      "event_count, created_at, updated_at) "
      "VALUES ('s1', 'media', 'Лост', 'completed', 0, 0, 0, 0)",
    );
    await v1.customStatement(
      "INSERT INTO media_items (item_id, media_type, format) "
      "VALUES ('s1', 'series', 'episodic')",
    );
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    // Переоткрываем: Drift видит user_version=1 < schemaVersion → onUpgrade.
    final v2 = AppDatabase(NativeDatabase(file));
    addTearDown(v2.close);
    final row = await v2
        .customSelect("SELECT media_type FROM media_items WHERE item_id = 's1'")
        .getSingle();
    expect(row.read<String>('media_type'), 'movie');
    expect(v2.schemaVersion, 4);
    // v2→v3 создал доменную таблицу vape_items (пустую, читается без ошибки);
    // v3→v4 добавил колонку damages_hardware (createTable выше уже создал её в
    // текущей схеме → addColumn для from<3 пропускается, конфликта нет).
    final vape = await v2
        .customSelect('SELECT COUNT(*) AS n, '
            'COUNT(damages_hardware) AS dh FROM vape_items')
        .getSingle();
    expect(vape.read<int>('n'), 0);
  });

  test('миграция v3→v4: добавляется колонка damages_hardware (default 0)',
      () async {
    final dir = Directory.systemTemp.createTempSync('kiseki_migrate_v3_');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });
    final file = File(p.join(dir.path, 'v3.sqlite'));

    // Поднимаем БД, пересоздаём vape_items в схеме v3 (БЕЗ damages_hardware) и
    // кладём строку, затем откатываем user_version к 3 — имитируем v3-БД.
    final v3 = AppDatabase(NativeDatabase(file));
    await v3.customStatement('DROP TABLE vape_items');
    await v3.customStatement(
      'CREATE TABLE vape_items ('
      'item_id TEXT NOT NULL PRIMARY KEY '
      'REFERENCES catalog_items (id) ON DELETE CASCADE, '
      'brand TEXT NOT NULL, nicotine_type TEXT NOT NULL, '
      'nicotine_strength TEXT NOT NULL, flavor_category TEXT, '
      'flavor_description TEXT, sweetness INTEGER, coolness INTEGER, '
      'richness INTEGER, can_rebuy INTEGER NOT NULL DEFAULT 0, '
      'flavor_fades INTEGER NOT NULL DEFAULT 0)',
    );
    await v3.customStatement(
      "INSERT INTO catalog_items (id, domain, title, status, is_favorite, "
      "event_count, created_at, updated_at) "
      "VALUES ('v1', 'vape', 'Манго', 'plan', 0, 0, 0, 0)",
    );
    await v3.customStatement(
      "INSERT INTO vape_items (item_id, brand, nicotine_type, "
      "nicotine_strength) VALUES ('v1', 'BrandX', 'salt', '20')",
    );
    await v3.customStatement('PRAGMA user_version = 3');
    await v3.close();

    // Переоткрываем: user_version=3 < 4 → onUpgrade добавляет damages_hardware.
    final v4 = AppDatabase(NativeDatabase(file));
    addTearDown(v4.close);
    final out = await v4
        .customSelect(
            "SELECT damages_hardware FROM vape_items WHERE item_id = 'v1'")
        .getSingle();
    expect(out.read<int>('damages_hardware'), 0);
    expect(v4.schemaVersion, 4);
  });
}

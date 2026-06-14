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
          mediaType: MediaType.series,
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
    expect(media.single.mediaType, MediaType.series);
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
}

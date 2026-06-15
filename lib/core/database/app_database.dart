import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;

import '../../features/media/data/media_converters.dart';
import '../error/failures.dart';
import '../../features/media/data/tables/media_items.dart';
import '../../features/media/domain/media_format.dart';
import '../../features/media/domain/media_type.dart';
import '../catalog/catalog_domain.dart';
import '../catalog/date_precision.dart';
import '../catalog/unfinished_reason.dart';
import '../catalog/watch_status.dart';
import 'converters.dart';
import 'fts.dart';
import 'tables/catalog_items.dart';
import 'tables/images.dart';
import 'tables/item_tags.dart';
import 'tables/tags.dart';

part 'app_database.g.dart';

/// Имя файла БД в каталоге приложения (рядом с `media/`, §7.2).
/// Используется и при открытии, и при restore (подмена файла).
const String kDbFileName = 'kiseki.sqlite';

/// SQLITE_FULL — диск/БД переполнены (primary result code, см. sqlite.org/rescode).
const int _sqliteFull = 13;

/// Корневая БД приложения (Drift поверх SQLite).
///
/// Список таблиц в `@DriftDatabase` — единственная вынужденная точка касания
/// ядра при добавлении домена (Drift статичен). FTS5 и триггеры создаются
/// сырым SQL в `onCreate` (см. [fts.dart]).
@DriftDatabase(tables: [CatalogItems, MediaItems, Images, Tags, ItemTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          for (final stmt in ftsAndTriggerStatements) {
            await customStatement(stmt);
          }
          for (final stmt in extraIndexStatements) {
            await customStatement(stmt);
          }
        },
        onUpgrade: (m, from, to) async {
          // v1→v2: код media_type 'series' свёрнут в 'movie'. Эпизодность
          // теперь несёт format (ADR-07), поэтому отдельный 'series' избыточен
          // — это та же категория «Фильм/Сериал» с format='episodic'. Структура
          // схемы не изменилась (data-only) → шаг миграции = один UPDATE.
          if (from < 2) {
            await customStatement(
              "UPDATE media_items SET media_type = 'movie' "
              "WHERE media_type = 'series'",
            );
          }
        },
        beforeOpen: (details) async {
          // В SQLite enforcement внешних ключей по умолчанию ВЫКЛЮЧЕН.
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  /// Полная пересборка FTS из базовых таблиц (после restore/миграции FTS).
  Future<void> rebuildFts() async {
    await customStatement(ftsRebuildClear);
    await customStatement(ftsRebuildFill);
  }

  /// Лёгкая проверка целостности при старте (TECH_DESIGN §9). `PRAGMA
  /// quick_check` возвращает 'ok' для здоровой БД; иначе (или при исключении
  /// открытия/создания/чтения) считаем БД повреждённой → экран восстановления.
  Future<bool> checkIntegrity() async => (await integrityReport()).ok;

  /// Как [checkIntegrity], но с технической причиной (для экрана восстановления
  /// и диагностики): сообщение исключения открытия/миграции либо результат
  /// quick_check, отличный от 'ok'.
  Future<({bool ok, String? detail})> integrityReport() async {
    try {
      final rows = await customSelect('PRAGMA quick_check').get();
      if (rows.isEmpty) return (ok: false, detail: 'quick_check вернул пусто');
      final v = rows.first.data.values.first;
      if (v == 'ok') return (ok: true, detail: null);
      return (ok: false, detail: 'quick_check: $v');
    } catch (e) {
      return (ok: false, detail: '$e');
    }
  }

  /// Транзакционно-консистентный снимок БД в файл [path] (для бэкапа, §8.1).
  /// `VACUUM INTO` корректно учитывает WAL и не требует остановки записи.
  Future<void> snapshotInto(String path) async {
    // VACUUM INTO требует НЕсуществующий целевой файл — иначе SQLite падает.
    // Safety-снимок пишется по фиксированному пути, так что без этой очистки
    // повторный restore в одной сессии валил бы снимок (молча).
    final target = File(path);
    if (target.existsSync()) target.deleteSync();
    final escaped = path.replaceAll("'", "''");
    try {
      await customStatement("VACUUM INTO '$escaped'");
    } on SqliteException catch (e) {
      // VACUUM при полном диске бросает SQLITE_FULL (не FileSystemException) —
      // даём типизированную ошибку, иначе бэкап показывал бы общий текст.
      if (e.resultCode == _sqliteFull) throw const StorageFullFailure();
      rethrow;
    }
    // VACUUM может сбросить user_version — проставляем явно, иначе при открытии
    // снимка Drift примет его за новую БД и запустит onCreate (createAll упадёт).
    await customStatement("ATTACH DATABASE '$escaped' AS _snap");
    await customStatement('PRAGMA _snap.user_version = $schemaVersion');
    await customStatement('DETACH DATABASE _snap');
  }
}

import 'package:drift/drift.dart';

import '../../features/media/data/media_converters.dart';
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

/// Корневая БД приложения (Drift поверх SQLite).
///
/// Список таблиц в `@DriftDatabase` — единственная вынужденная точка касания
/// ядра при добавлении домена (Drift статичен). FTS5 и триггеры создаются
/// сырым SQL в `onCreate` (см. [fts.dart]).
@DriftDatabase(tables: [CatalogItems, MediaItems, Images, Tags, ItemTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

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
  /// открытия/чтения) считаем БД повреждённой → экран восстановления.
  Future<bool> checkIntegrity() async {
    try {
      final rows = await customSelect('PRAGMA quick_check').get();
      if (rows.isEmpty) return false;
      return rows.first.data.values.first == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Транзакционно-консистентный снимок БД в файл [path] (для бэкапа, §8.1).
  /// `VACUUM INTO` корректно учитывает WAL и не требует остановки записи.
  Future<void> snapshotInto(String path) async {
    final escaped = path.replaceAll("'", "''");
    await customStatement("VACUUM INTO '$escaped'");
    // VACUUM может сбросить user_version — проставляем явно, иначе при открытии
    // снимка Drift примет его за новую БД и запустит onCreate (createAll упадёт).
    await customStatement("ATTACH DATABASE '$escaped' AS _snap");
    await customStatement('PRAGMA _snap.user_version = $schemaVersion');
    await customStatement('DETACH DATABASE _snap');
  }
}

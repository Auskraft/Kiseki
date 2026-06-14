import 'package:drift/drift.dart';

import '../converters.dart';

/// ЯДРО картотеки — общие поля всех доменов (TECH_DESIGN §4.2).
/// Время — INTEGER Unix-мс UTC через [DateTimeMsConverter]. Имена колонок —
/// snake_case (Drift по умолчанию): `isFavorite` -> `is_favorite` и т.д.
class CatalogItems extends Table {
  @override
  String get tableName => 'catalog_items';

  /// UUID v4, генерирует приложение до вставки.
  TextColumn get id => text()();

  TextColumn get domain => text().map(const CatalogDomainConverter())();

  TextColumn get title => text().withLength(min: 1, max: 500)();

  IntColumn get rating => integer().nullable()();

  TextColumn get status => text().map(const WatchStatusConverter())();

  TextColumn get unfinishedReason =>
      text().map(const UnfinishedReasonConverter()).nullable()();

  TextColumn get note => text().nullable()();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  /// Обобщённый счётчик «событий»: для медиа — пересмотры (ADR / §4.2).
  IntColumn get eventCount => integer().withDefault(const Constant(0))();

  // Пользовательские даты + точность (день/месяц/год). NULL допустим.
  IntColumn get startedAt =>
      integer().map(const DateTimeMsConverter()).nullable()();
  TextColumn get startedAtPrec =>
      text().map(const DatePrecisionConverter()).nullable()();

  IntColumn get lastActivityAt =>
      integer().map(const DateTimeMsConverter()).nullable()();
  TextColumn get lastActivityAtPrec =>
      text().map(const DatePrecisionConverter()).nullable()();

  IntColumn get finishedAt =>
      integer().map(const DateTimeMsConverter()).nullable()();
  TextColumn get finishedAtPrec =>
      text().map(const DatePrecisionConverter()).nullable()();

  // Служебные метки.
  IntColumn get createdAt => integer().map(const DateTimeMsConverter())();
  IntColumn get updatedAt => integer().map(const DateTimeMsConverter())();
  IntColumn get deletedAt =>
      integer().map(const DateTimeMsConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
        'CHECK (rating IS NULL OR rating BETWEEN 0 AND 100)',
        'CHECK (note IS NULL OR length(note) <= 10000)',
        'CHECK (event_count >= 0)',
      ];
}

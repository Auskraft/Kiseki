import 'package:drift/drift.dart';

import '../../../../core/database/tables/catalog_items.dart';
import '../media_converters.dart';

/// Домен «медиа» — специализация 1:1 к ядру (PK = FK -> catalog_items.id).
/// CHECK-инварианты держат целостность фильм/сериал (TECH_DESIGN §4.2, ADR-07).
class MediaItems extends Table {
  @override
  String get tableName => 'media_items';

  TextColumn get itemId =>
      text().references(CatalogItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get mediaType => text().map(const MediaTypeConverter())();

  TextColumn get format => text().map(const MediaFormatConverter())();

  TextColumn get originalTitle => text().nullable()();

  IntColumn get year => integer().nullable()();

  /// ISO 3166-1 alpha-2 (KR/JP/CN/...).
  TextColumn get country => text().withLength(min: 2, max: 2).nullable()();

  IntColumn get currentSeason => integer().nullable()();
  IntColumn get currentEpisode => integer().nullable()();
  IntColumn get totalSeasons => integer().nullable()();
  IntColumn get totalEpisodes => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};

  @override
  List<String> get customConstraints => const [
        'CHECK (year IS NULL OR year BETWEEN 1888 AND 2100)',
        // Сезонные поля существуют только у episodic:
        "CHECK (format = 'episodic' OR (current_season IS NULL "
            'AND current_episode IS NULL AND total_seasons IS NULL '
            'AND total_episodes IS NULL))',
        // Серия требует сезон (для одно-сезонных UI пишет season=1):
        'CHECK (current_episode IS NULL OR current_season IS NOT NULL)',
      ];
}

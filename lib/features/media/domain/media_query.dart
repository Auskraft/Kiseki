import '../../../core/catalog/unfinished_reason.dart';
import '../../../core/catalog/watch_status.dart';
import 'media_format.dart';
import 'media_type.dart';

enum CatalogSortField {
  updatedAt,
  createdAt,
  rating,
  title,
  year,
  lastActivityAt,
  finishedAt,
}

enum SortDirection { asc, desc }

/// Спецификация фильтра+сортировки для списка медиа (TECH_DESIGN §6.7).
/// Пустые множества = «без ограничения». Назван `MediaListQuery`, чтобы не
/// конфликтовать с Flutter `MediaQuery`.
class MediaListQuery {
  const MediaListQuery({
    this.text,
    this.statuses = const {},
    this.mediaTypes = const {},
    this.formats = const {},
    this.tagIds = const {},
    this.unfinishedReasons = const {},
    this.ratingMin,
    this.ratingMax,
    this.onlyUnrated = false,
    this.onlyFavorites = false,
    this.includeDeleted = false,
    this.sortField = CatalogSortField.updatedAt,
    this.sortDirection = SortDirection.desc,
  });

  /// Полнотекстовый запрос (FTS5). `null`/пусто = без поиска.
  final String? text;
  final Set<WatchStatus> statuses;
  final Set<MediaType> mediaTypes;
  final Set<MediaFormat> formats;
  final Set<String> tagIds;
  final Set<UnfinishedReason> unfinishedReasons;
  final int? ratingMin;
  final int? ratingMax;
  final bool onlyUnrated;
  final bool onlyFavorites;

  /// `false` — только живые записи; `true` — только корзина.
  final bool includeDeleted;

  final CatalogSortField sortField;
  final SortDirection sortDirection;
}

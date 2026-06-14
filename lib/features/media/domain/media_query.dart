import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
class MediaListQuery extends Equatable {
  const MediaListQuery({
    this.text,
    this.statuses = const {},
    this.mediaTypes = const {},
    this.formats = const {},
    this.tagIds = const {},
    this.unfinishedReasons = const {},
    this.countries = const {},
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
  final Set<String> countries;
  final int? ratingMin;
  final int? ratingMax;
  final bool onlyUnrated;
  final bool onlyFavorites;

  /// `false` — только живые записи; `true` — только корзина.
  final bool includeDeleted;

  final CatalogSortField sortField;
  final SortDirection sortDirection;

  /// Есть ли активные ограничения (для индикатора фильтра и пустого состояния).
  /// Поиск и сортировка сюда НЕ входят — учитываются отдельно.
  bool get hasFilters =>
      statuses.isNotEmpty ||
      mediaTypes.isNotEmpty ||
      formats.isNotEmpty ||
      tagIds.isNotEmpty ||
      unfinishedReasons.isNotEmpty ||
      countries.isNotEmpty ||
      ratingMin != null ||
      ratingMax != null ||
      onlyUnrated ||
      onlyFavorites;

  bool get hasSearch => text != null && text!.isNotEmpty;

  MediaListQuery copyWith({
    ValueGetter<String?>? text,
    Set<WatchStatus>? statuses,
    Set<MediaType>? mediaTypes,
    Set<MediaFormat>? formats,
    Set<String>? tagIds,
    Set<UnfinishedReason>? unfinishedReasons,
    Set<String>? countries,
    ValueGetter<int?>? ratingMin,
    ValueGetter<int?>? ratingMax,
    bool? onlyUnrated,
    bool? onlyFavorites,
    bool? includeDeleted,
    CatalogSortField? sortField,
    SortDirection? sortDirection,
  }) {
    return MediaListQuery(
      text: text != null ? text() : this.text,
      statuses: statuses ?? this.statuses,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      formats: formats ?? this.formats,
      tagIds: tagIds ?? this.tagIds,
      unfinishedReasons: unfinishedReasons ?? this.unfinishedReasons,
      countries: countries ?? this.countries,
      ratingMin: ratingMin != null ? ratingMin() : this.ratingMin,
      ratingMax: ratingMax != null ? ratingMax() : this.ratingMax,
      onlyUnrated: onlyUnrated ?? this.onlyUnrated,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  @override
  List<Object?> get props => [
        text,
        statuses,
        mediaTypes,
        formats,
        tagIds,
        unfinishedReasons,
        countries,
        ratingMin,
        ratingMax,
        onlyUnrated,
        onlyFavorites,
        includeDeleted,
        sortField,
        sortDirection,
      ];
}

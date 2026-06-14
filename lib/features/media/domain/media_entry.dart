import 'package:equatable/equatable.dart';

import '../../../core/catalog/catalog_date.dart';
import '../../../core/catalog/catalog_image.dart';
import '../../../core/catalog/rating.dart';
import '../../../core/catalog/tag.dart';
import '../../../core/catalog/unfinished_reason.dart';
import '../../../core/catalog/watch_status.dart';
import 'media_format.dart';
import 'media_type.dart';

/// Доменная модель карточки медиа (read-модель, отделена от Drift-строк).
/// Объединяет поля ядра и медиа-специфику + связанные теги/картинки.
class MediaEntry extends Equatable {
  const MediaEntry({
    required this.id,
    required this.title,
    required this.status,
    required this.mediaType,
    required this.format,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.unfinishedReason,
    this.note,
    this.isFavorite = false,
    this.rewatchCount = 0,
    this.originalTitle,
    this.year,
    this.country,
    this.currentSeason,
    this.currentEpisode,
    this.totalSeasons,
    this.totalEpisodes,
    this.startedAt,
    this.lastActivityAt,
    this.finishedAt,
    this.tags = const [],
    this.images = const [],
    this.deletedAt,
  });

  final String id;
  final String title;
  final WatchStatus status;
  final MediaType mediaType;
  final MediaFormat format;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Rating? rating;
  final UnfinishedReason? unfinishedReason;
  final String? note;
  final bool isFavorite;

  /// Счётчик пересмотров (отражает общее ядровое `event_count`).
  final int rewatchCount;

  final String? originalTitle;
  final int? year;
  final String? country;

  final int? currentSeason;
  final int? currentEpisode;
  final int? totalSeasons;
  final int? totalEpisodes;

  final CatalogDate? startedAt;
  final CatalogDate? lastActivityAt;
  final CatalogDate? finishedAt;

  final List<Tag> tags;
  final List<CatalogImage> images;

  final DateTime? deletedAt;

  bool get isInTrash => deletedAt != null;

  bool get isEpisodic => format == MediaFormat.episodic;

  /// Обложка = картинка с наименьшим `position` (или `null`).
  CatalogImage? get cover {
    if (images.isEmpty) return null;
    final sorted = [...images]..sort((a, b) => a.position.compareTo(b.position));
    return sorted.first;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        status,
        mediaType,
        format,
        createdAt,
        updatedAt,
        rating,
        unfinishedReason,
        note,
        isFavorite,
        rewatchCount,
        originalTitle,
        year,
        country,
        currentSeason,
        currentEpisode,
        totalSeasons,
        totalEpisodes,
        startedAt,
        lastActivityAt,
        finishedAt,
        tags,
        images,
        deletedAt,
      ];
}

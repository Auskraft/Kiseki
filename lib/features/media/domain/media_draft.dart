import '../../../core/catalog/catalog_date.dart';
import '../../../core/catalog/rating.dart';
import '../../../core/catalog/unfinished_reason.dart';
import '../../../core/catalog/watch_status.dart';
import 'media_format.dart';
import 'media_type.dart';

/// Входная модель создания/редактирования карточки (без id и служебных дат —
/// их назначает репозиторий). `tagIds` — id уже существующих тегов.
class MediaDraft {
  const MediaDraft({
    required this.title,
    required this.mediaType,
    required this.format,
    this.status = WatchStatus.plan,
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
    this.tagIds = const [],
    this.coverImageId,
  });

  final String title;
  final MediaType mediaType;
  final MediaFormat format;
  final WatchStatus status;
  final Rating? rating;
  final UnfinishedReason? unfinishedReason;
  final String? note;
  final bool isFavorite;
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
  final List<String> tagIds;

  /// UUID обложки (файлы уже сохранены [ImageStorage]). `null` — без обложки.
  /// Репозиторий записывает строку `images` в той же транзакции (§4.5).
  final String? coverImageId;
}

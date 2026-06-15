import '../core/catalog/rating.dart';
import '../core/catalog/tag_repository.dart';
import '../core/catalog/unfinished_reason.dart';
import '../core/catalog/watch_status.dart';
import '../features/media/domain/media_draft.dart';
import '../features/media/domain/media_format.dart';
import '../features/media/domain/media_repository.dart';
import '../features/media/domain/media_type.dart';

/// DEV-ONLY: засеять демонстрационные карточки, чтобы видеть UI с данными
/// (вызывается в debug, если картотека пуста). Не часть продакшна.
Future<void> seedDemoData(MediaRepository repo, TagRepository tags) async {
  final drama = await tags.ensure('Драма');
  final crime = await tags.ensure('Криминал');
  final scifi = await tags.ensure('Sci-Fi');
  final fantasy = await tags.ensure('Фэнтези');

  await repo.create(MediaDraft(
    title: 'Во все тяжкие',
    originalTitle: 'Breaking Bad',
    mediaType: MediaType.movie,
    format: MediaFormat.episodic,
    status: WatchStatus.completed,
    rating: const Rating(96),
    year: 2008,
    country: 'US',
    currentSeason: 5,
    currentEpisode: 16,
    totalSeasons: 5,
    totalEpisodes: 62,
    isFavorite: true,
    rewatchCount: 1,
    tagIds: [drama.id, crime.id],
  ));

  await repo.create(MediaDraft(
    title: 'Игра престолов',
    originalTitle: 'Game of Thrones',
    mediaType: MediaType.movie,
    format: MediaFormat.episodic,
    status: WatchStatus.watching,
    rating: const Rating(78),
    year: 2011,
    country: 'US',
    currentSeason: 2,
    currentEpisode: 5,
    totalSeasons: 8,
    tagIds: [fantasy.id, drama.id],
  ));

  await repo.create(MediaDraft(
    title: 'Атака титанов',
    originalTitle: '進撃の巨人',
    mediaType: MediaType.anime,
    format: MediaFormat.episodic,
    status: WatchStatus.paused,
    unfinishedReason: UnfinishedReason.waitingEpisodes,
    rating: const Rating(88),
    year: 2013,
    country: 'JP',
    currentSeason: 4,
    currentEpisode: 28,
    isFavorite: true,
    tagIds: [fantasy.id],
  ));

  await repo.create(MediaDraft(
    title: 'Твоё имя',
    originalTitle: '君の名は。',
    mediaType: MediaType.anime,
    format: MediaFormat.single,
    status: WatchStatus.completed,
    rating: const Rating(91),
    year: 2016,
    country: 'JP',
  ));

  await repo.create(const MediaDraft(
    title: 'Властелин колец: Братство кольца',
    mediaType: MediaType.movie,
    format: MediaFormat.single,
    status: WatchStatus.completed,
    rating: Rating(95),
    year: 2001,
    isFavorite: true,
  ));

  await repo.create(MediaDraft(
    title: 'Очень странные дела',
    originalTitle: 'Stranger Things',
    mediaType: MediaType.movie,
    format: MediaFormat.episodic,
    status: WatchStatus.plan,
    year: 2016,
    country: 'US',
    tagIds: [scifi.id],
  ));

  await repo.create(MediaDraft(
    title: 'Эйфория',
    mediaType: MediaType.drama,
    format: MediaFormat.episodic,
    status: WatchStatus.dropped,
    unfinishedReason: UnfinishedReason.notForMe,
    rating: const Rating(45),
    year: 2019,
    country: 'US',
    currentSeason: 1,
    currentEpisode: 3,
    tagIds: [drama.id],
  ));

  await repo.create(MediaDraft(
    title: 'Восхождение Юпитер',
    mediaType: MediaType.movie,
    format: MediaFormat.episodic,
    status: WatchStatus.watching,
    rating: const Rating(72),
    year: 2022,
    currentSeason: 1,
    currentEpisode: 6,
    totalSeasons: 1,
    totalEpisodes: 10,
    tagIds: [scifi.id],
  ));
}

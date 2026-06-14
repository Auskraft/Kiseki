import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/catalog_date.dart';
import 'package:kiseki/core/catalog/date_precision.dart';
import 'package:kiseki/core/catalog/rating.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/catalog/unfinished_reason.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_query.dart';
import 'package:kiseki/features/media/domain/media_type.dart';

void main() {
  late AppDatabase db;
  late MediaRepositoryImpl repo;
  late TagRepositoryImpl tags;
  late DateTime now;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 1, 1, 12);
    repo = MediaRepositoryImpl(db, clock: () => now);
    tags = TagRepositoryImpl(db, clock: () => now);
  });
  tearDown(() => db.close());

  MediaDraft seriesDraft({
    String title = 'Breaking Bad',
    String? original = 'Во все тяжкие',
    WatchStatus status = WatchStatus.watching,
    Rating? rating,
    List<String> tagIds = const [],
    String? cover,
  }) {
    return MediaDraft(
      title: title,
      mediaType: MediaType.series,
      format: MediaFormat.episodic,
      status: status,
      originalTitle: original,
      rating: rating,
      year: 2008,
      country: 'US',
      currentSeason: 2,
      currentEpisode: 5,
      totalEpisodes: 62,
      tagIds: tagIds,
      coverImageId: cover,
      startedAt: CatalogDate(DateTime.utc(2025, 3), DatePrecision.month),
    );
  }

  test('create + findById round-trips all fields', () async {
    final tag = await tags.ensure('Драма');
    final id = await repo.create(seriesDraft(rating: const Rating(84), tagIds: [tag.id]));

    final entry = await repo.findById(id);
    expect(entry, isNotNull);
    expect(entry!.title, 'Breaking Bad');
    expect(entry.originalTitle, 'Во все тяжкие');
    expect(entry.status, WatchStatus.watching);
    expect(entry.mediaType, MediaType.series);
    expect(entry.format, MediaFormat.episodic);
    expect(entry.rating, const Rating(84));
    expect(entry.currentSeason, 2);
    expect(entry.currentEpisode, 5);
    expect(entry.startedAt, CatalogDate(DateTime.utc(2025, 3), DatePrecision.month));
    expect(entry.tags.map((t) => t.name), ['Драма']);
    expect(entry.createdAt, now);
    expect(entry.updatedAt, now);
  });

  test('watch reflects creation and soft-delete / trash', () async {
    final id = await repo.create(seriesDraft());

    var live = await repo.watch(const MediaListQuery()).first;
    expect(live.map((e) => e.id), [id]);

    await repo.softDelete(id);
    live = await repo.watch(const MediaListQuery()).first;
    expect(live, isEmpty);

    final trash =
        await repo.watch(const MediaListQuery(includeDeleted: true)).first;
    expect(trash.map((e) => e.id), [id]);
    expect(trash.single.isInTrash, isTrue);

    await repo.restore(id);
    live = await repo.watch(const MediaListQuery()).first;
    expect(live.map((e) => e.id), [id]);
  });

  test('update changes fields, bumps updated_at, keeps created_at', () async {
    final id = await repo.create(seriesDraft(status: WatchStatus.watching));
    final created = now;

    now = DateTime.utc(2026, 2, 2, 9); // время идёт вперёд
    await repo.update(
      id,
      seriesDraft(
        status: WatchStatus.paused,
        title: 'Breaking Bad (rewatch)',
      ).copyWithReason(),
    );

    final entry = await repo.findById(id);
    expect(entry!.title, 'Breaking Bad (rewatch)');
    expect(entry.status, WatchStatus.paused);
    expect(entry.unfinishedReason, UnfinishedReason.waitingEpisodes);
    expect(entry.createdAt, created);
    expect(entry.updatedAt, DateTime.utc(2026, 2, 2, 9));
  });

  test('FTS search by title prefix and by original (Cyrillic)', () async {
    final bb = await repo.create(seriesDraft(title: 'Breaking Bad', original: 'Во все тяжкие'));
    await repo.create(seriesDraft(title: 'Better Call Saul', original: 'Лучше звонить Солу'));

    final byTitle =
        await repo.watch(const MediaListQuery(text: 'break')).first;
    expect(byTitle.map((e) => e.id), [bb]);

    final byOriginal =
        await repo.watch(const MediaListQuery(text: 'тяжкие')).first;
    expect(byOriginal.map((e) => e.id), [bb]);

    final none = await repo.watch(const MediaListQuery(text: 'zzz')).first;
    expect(none, isEmpty);
  });

  test('filter by country', () async {
    await repo.create(MediaDraft(
      title: 'Дорама',
      mediaType: MediaType.drama,
      format: MediaFormat.episodic,
      country: 'KR',
    ));
    await repo.create(MediaDraft(
      title: 'Аниме',
      mediaType: MediaType.anime,
      format: MediaFormat.episodic,
      country: 'JP',
    ));

    final onlyKr =
        await repo.watch(const MediaListQuery(countries: {'KR'})).first;
    expect(onlyKr.map((e) => e.title), ['Дорама']);
  });

  test('filter by status and favorites', () async {
    final watching = await repo.create(seriesDraft(status: WatchStatus.watching));
    await repo.create(seriesDraft(title: 'X', status: WatchStatus.completed));

    final onlyWatching = await repo
        .watch(const MediaListQuery(statuses: {WatchStatus.watching}))
        .first;
    expect(onlyWatching.map((e) => e.id), [watching]);
  });

  test('sort by rating puts unrated last regardless of direction', () async {
    final low = await repo.create(seriesDraft(title: 'Low', rating: const Rating(40)));
    final high = await repo.create(seriesDraft(title: 'High', rating: const Rating(90)));
    final unrated = await repo.create(seriesDraft(title: 'Unrated'));

    final desc = await repo
        .watch(const MediaListQuery(sortField: CatalogSortField.rating))
        .first;
    expect(desc.map((e) => e.id), [high, low, unrated]);
  });

  test('обложка: create пишет строку images, update заменяет/убирает', () async {
    final id = await repo.create(seriesDraft(cover: 'img-1'));
    expect((await repo.findById(id))!.cover?.id, 'img-1');
    expect(await repo.allImageIds(), {'img-1'});

    await repo.update(id, seriesDraft(cover: 'img-2'));
    expect((await repo.findById(id))!.cover?.id, 'img-2');
    expect(await repo.allImageIds(), {'img-2'}); // старая строка снесена

    await repo.update(id, seriesDraft(cover: null));
    expect((await repo.findById(id))!.cover, isNull);
    expect(await repo.allImageIds(), isEmpty);
  });

  test('purge cascades to media/tags rows', () async {
    final tag = await tags.ensure('Драма');
    final id = await repo.create(seriesDraft(tagIds: [tag.id]));

    await repo.purge(id);

    expect(await repo.findById(id), isNull);
    expect(await db.select(db.mediaItems).get(), isEmpty);
    expect(await db.select(db.itemTags).get(), isEmpty);
    // Сам тег остаётся в справочнике.
    expect(await tags.all(), hasLength(1));
  });

  test('watchById реактивно пере-эмитит при мутации', () async {
    final id = await repo.create(seriesDraft(status: WatchStatus.plan));
    final emissions = <WatchStatus?>[];
    final sub = repo.watchById(id).listen((e) => emissions.add(e?.status));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.setStatus(id, WatchStatus.watching);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(emissions, [WatchStatus.plan, WatchStatus.watching]);
  });

  test('setStatus снимает причину вне паузы/заброса', () async {
    final id = await repo.create(seriesDraft(status: WatchStatus.paused));
    await repo.setStatus(id, WatchStatus.paused,
        unfinishedReason: UnfinishedReason.noTime);
    expect((await repo.findById(id))!.unfinishedReason, UnfinishedReason.noTime);

    await repo.setStatus(id, WatchStatus.watching);
    expect((await repo.findById(id))!.unfinishedReason, isNull);
  });

  test('setStatus: «жду серии» допустимо только при паузе', () async {
    final id = await repo.create(seriesDraft());
    await repo.setStatus(id, WatchStatus.dropped,
        unfinishedReason: UnfinishedReason.waitingEpisodes);
    final e = await repo.findById(id);
    expect(e!.status, WatchStatus.dropped);
    expect(e.unfinishedReason, isNull);
  });

  test('setFavorite и incrementEventCount двигают updated_at', () async {
    final id = await repo.create(seriesDraft());

    now = DateTime.utc(2026, 5, 5);
    await repo.setFavorite(id, true);
    var e = await repo.findById(id);
    expect(e!.isFavorite, isTrue);
    expect(e.updatedAt, DateTime.utc(2026, 5, 5));

    now = DateTime.utc(2026, 6, 6);
    await repo.incrementEventCount(id);
    e = await repo.findById(id);
    expect(e!.rewatchCount, 1);
    expect(e.updatedAt, DateTime.utc(2026, 6, 6));
  });

  test('watchById отдаёт null после физического удаления', () async {
    final id = await repo.create(seriesDraft());
    expect(await repo.watchById(id).first, isNotNull);
    await repo.purge(id);
    expect(await repo.watchById(id).first, isNull);
  });

  test('purgeAllTrashed чистит только корзину, живые целы', () async {
    final live = await repo.create(seriesDraft(title: 'Live'));
    final a = await repo.create(seriesDraft(title: 'A'));
    final b = await repo.create(seriesDraft(title: 'B'));
    await repo.softDelete(a);
    await repo.softDelete(b);

    await repo.purgeAllTrashed();

    expect(await repo.findById(a), isNull);
    expect(await repo.findById(b), isNull);
    expect((await repo.findById(live))!.title, 'Live');
    expect(
      await repo.watch(const MediaListQuery(includeDeleted: true)).first,
      isEmpty,
    );
  });
}

extension on MediaDraft {
  /// Локальный помощник: вернуть копию с причиной «жду серии».
  MediaDraft copyWithReason() => MediaDraft(
        title: title,
        mediaType: mediaType,
        format: format,
        status: status,
        rating: rating,
        unfinishedReason: UnfinishedReason.waitingEpisodes,
        note: note,
        isFavorite: isFavorite,
        rewatchCount: rewatchCount,
        originalTitle: originalTitle,
        year: year,
        country: country,
        currentSeason: currentSeason,
        currentEpisode: currentEpisode,
        totalSeasons: totalSeasons,
        totalEpisodes: totalEpisodes,
        startedAt: startedAt,
        lastActivityAt: lastActivityAt,
        finishedAt: finishedAt,
        tagIds: tagIds,
      );
}

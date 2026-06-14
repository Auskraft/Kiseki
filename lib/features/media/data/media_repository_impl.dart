import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/catalog/catalog_date.dart';
import '../../../core/catalog/catalog_domain.dart';
import '../../../core/catalog/catalog_image.dart';
import '../../../core/catalog/date_precision.dart';
import '../../../core/catalog/rating.dart';
import '../../../core/catalog/tag.dart';
import '../../../core/catalog/unfinished_reason.dart';
import '../../../core/catalog/watch_status.dart';
import '../../../core/database/app_database.dart';
import '../domain/media_draft.dart';
import '../domain/media_entry.dart';
import '../domain/media_format.dart';
import '../domain/media_query.dart';
import '../domain/media_repository.dart';
import '../domain/media_type.dart';

/// Реализация [MediaRepository] поверх Drift.
///
/// Все мульти-табличные мутации — в одной транзакции, порядок ядро→домен.
/// Любая правка двигает `catalog_items.updated_at` (инвариант LWW, ADR-06).
/// `clock`/`uuid` инжектируются для детерминированных тестов.
class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(
    this._db, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  })  : _uuid = uuid,
        _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  static const _select = 'SELECT c.*, m.media_type, m.format, m.original_title, '
      'm.year, m.country, m.current_season, m.current_episode, '
      'm.total_seasons, m.total_episodes '
      'FROM catalog_items c JOIN media_items m ON m.item_id = c.id';

  @override
  Stream<List<MediaEntry>> watch(MediaListQuery query) {
    final (where, vars) = _buildWhere(query);
    final sql = '$_select'
        '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}'
        ' ${_buildOrderBy(query)}';
    return _db
        .customSelect(
          sql,
          variables: vars,
          readsFrom: {
            _db.catalogItems,
            _db.mediaItems,
            _db.itemTags,
            _db.images,
            _db.tags,
          },
        )
        .watch()
        .asyncMap(_attachAndMap);
  }

  @override
  Stream<MediaEntry?> watchById(String id) {
    return _db
        .customSelect(
          '$_select WHERE c.id = ?',
          variables: [Variable<String>(id)],
          readsFrom: {
            _db.catalogItems,
            _db.mediaItems,
            _db.itemTags,
            _db.images,
            _db.tags,
          },
        )
        .watch()
        .asyncMap((rows) async {
      if (rows.isEmpty) return null;
      return (await _attachAndMap(rows)).first;
    });
  }

  @override
  Future<MediaEntry?> findById(String id) async {
    final rows = await _db.customSelect(
      '$_select WHERE c.id = ?',
      variables: [Variable<String>(id)],
    ).get();
    if (rows.isEmpty) return null;
    return (await _attachAndMap(rows)).first;
  }

  @override
  Future<String> create(MediaDraft draft) async {
    final id = _uuid.v4();
    final now = _now();
    await _db.transaction(() async {
      await _db.into(_db.catalogItems).insert(_coreInsert(id, draft, now));
      await _db.into(_db.mediaItems).insert(_mediaInsert(id, draft));
      await _linkTags(id, draft.tagIds);
      await _setCover(id, draft.coverImageId, now);
    });
    return id;
  }

  @override
  Future<void> update(String id, MediaDraft draft) async {
    final now = _now();
    await _db.transaction(() async {
      await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id)))
          .write(_coreUpdate(draft, now));
      await (_db.update(_db.mediaItems)..where((t) => t.itemId.equals(id)))
          .write(_mediaUpdate(draft));
      await (_db.delete(_db.itemTags)..where((t) => t.itemId.equals(id))).go();
      await _linkTags(id, draft.tagIds);
      await _setCover(id, draft.coverImageId, now);
    });
  }

  @override
  Future<void> setStatus(String id, WatchStatus status,
      {UnfinishedReason? unfinishedReason}) async {
    final now = _now();
    var reason = unfinishedReason;
    if (status != WatchStatus.paused && status != WatchStatus.dropped) {
      reason = null;
    }
    if (reason == UnfinishedReason.waitingEpisodes &&
        status != WatchStatus.paused) {
      reason = null;
    }
    await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id))).write(
      CatalogItemsCompanion(
        status: Value(status),
        unfinishedReason: Value(reason),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> setFavorite(String id, bool isFavorite) async {
    final now = _now();
    await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id))).write(
      CatalogItemsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> incrementEventCount(String id) async {
    final now = _now();
    await _db.customUpdate(
      'UPDATE catalog_items SET event_count = event_count + 1, updated_at = ? '
      'WHERE id = ?',
      variables: [
        Variable<int>(now.millisecondsSinceEpoch),
        Variable<String>(id),
      ],
      updates: {_db.catalogItems},
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = _now();
    await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id))).write(
      CatalogItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  @override
  Future<void> restore(String id) async {
    final now = _now();
    await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id))).write(
      CatalogItemsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> purge(String id) async {
    // CASCADE убирает media_items/item_tags/images; FTS-строку снимает триггер.
    await (_db.delete(_db.catalogItems)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> purgeAllTrashed() async {
    await _db.customUpdate(
      'DELETE FROM catalog_items WHERE domain = ? AND deleted_at IS NOT NULL',
      variables: [Variable<String>(CatalogDomain.media.code)],
      updates: {_db.catalogItems},
      updateKind: UpdateKind.delete,
    );
  }

  @override
  Future<Set<String>> allImageIds() async {
    final rows = await _db.customSelect('SELECT id FROM images').get();
    return rows.map((r) => r.read<String>('id')).toSet();
  }

  // ─────────────────────────── companions ───────────────────────────

  CatalogItemsCompanion _coreInsert(String id, MediaDraft d, DateTime now) {
    return CatalogItemsCompanion.insert(
      id: id,
      domain: CatalogDomain.media,
      title: d.title,
      status: d.status,
      createdAt: now,
      updatedAt: now,
      rating: Value(d.rating?.value),
      unfinishedReason: Value(d.unfinishedReason),
      note: Value(d.note),
      isFavorite: Value(d.isFavorite),
      eventCount: Value(d.rewatchCount),
      startedAt: Value(d.startedAt?.value),
      startedAtPrec: Value(d.startedAt?.precision),
      lastActivityAt: Value(d.lastActivityAt?.value),
      lastActivityAtPrec: Value(d.lastActivityAt?.precision),
      finishedAt: Value(d.finishedAt?.value),
      finishedAtPrec: Value(d.finishedAt?.precision),
    );
  }

  CatalogItemsCompanion _coreUpdate(MediaDraft d, DateTime now) {
    return CatalogItemsCompanion(
      title: Value(d.title),
      status: Value(d.status),
      rating: Value(d.rating?.value),
      unfinishedReason: Value(d.unfinishedReason),
      note: Value(d.note),
      isFavorite: Value(d.isFavorite),
      eventCount: Value(d.rewatchCount),
      startedAt: Value(d.startedAt?.value),
      startedAtPrec: Value(d.startedAt?.precision),
      lastActivityAt: Value(d.lastActivityAt?.value),
      lastActivityAtPrec: Value(d.lastActivityAt?.precision),
      finishedAt: Value(d.finishedAt?.value),
      finishedAtPrec: Value(d.finishedAt?.precision),
      updatedAt: Value(now),
    );
  }

  /// CHECK-безопасные сезонные поля (§4.5.4, инвариант 4): только у `episodic`,
  /// серия влечёт сезон. Нормализуем В РЕПОЗИТОРИИ, чтобы инвариант держался
  /// для ЛЮБОГО вызывающего (импорт/мёрж/dev), а не только редактора.
  (int?, int?, int?, int?) _seasonFields(MediaDraft d) {
    if (d.format != MediaFormat.episodic) return (null, null, null, null);
    final season = (d.currentEpisode != null && d.currentSeason == null)
        ? 1
        : d.currentSeason;
    return (season, d.currentEpisode, d.totalSeasons, d.totalEpisodes);
  }

  MediaItemsCompanion _mediaInsert(String id, MediaDraft d) {
    final (season, episode, totalSeasons, totalEpisodes) = _seasonFields(d);
    return MediaItemsCompanion.insert(
      itemId: id,
      mediaType: d.mediaType,
      format: d.format,
      originalTitle: Value(d.originalTitle),
      year: Value(d.year),
      country: Value(d.country),
      currentSeason: Value(season),
      currentEpisode: Value(episode),
      totalSeasons: Value(totalSeasons),
      totalEpisodes: Value(totalEpisodes),
    );
  }

  MediaItemsCompanion _mediaUpdate(MediaDraft d) {
    final (season, episode, totalSeasons, totalEpisodes) = _seasonFields(d);
    return MediaItemsCompanion(
      mediaType: Value(d.mediaType),
      format: Value(d.format),
      originalTitle: Value(d.originalTitle),
      year: Value(d.year),
      country: Value(d.country),
      currentSeason: Value(season),
      currentEpisode: Value(episode),
      totalSeasons: Value(totalSeasons),
      totalEpisodes: Value(totalEpisodes),
    );
  }

  Future<void> _linkTags(String itemId, List<String> tagIds) async {
    for (final tagId in tagIds.toSet()) {
      await _db.into(_db.itemTags).insert(
            ItemTagsCompanion.insert(itemId: itemId, tagId: tagId),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// Единственная обложка (итерация 1): сносим строки `images` карточки и
  /// ставим новую (если есть). Файлы пишет/чистит вызывающий слой (§4.5/§7.3).
  Future<void> _setCover(String itemId, String? coverId, DateTime now) async {
    await (_db.delete(_db.images)..where((t) => t.itemId.equals(itemId))).go();
    if (coverId != null) {
      await _db.into(_db.images).insert(
            ImagesCompanion.insert(id: coverId, itemId: itemId, createdAt: now),
          );
    }
  }

  // ─────────────────────────── reading ───────────────────────────

  Future<List<MediaEntry>> _attachAndMap(List<QueryRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.read<String>('id')).toList();
    final tagsByItem = await _loadTags(ids);
    final imagesByItem = await _loadImages(ids);
    return rows.map((r) {
      final id = r.read<String>('id');
      return _rowToEntry(
        r,
        tagsByItem[id] ?? const [],
        imagesByItem[id] ?? const [],
      );
    }).toList();
  }

  Future<Map<String, List<Tag>>> _loadTags(List<String> ids) async {
    final query = _db.select(_db.itemTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.itemTags.tagId)),
    ])
      ..where(_db.itemTags.itemId.isIn(ids));
    final rows = await query.get();
    final map = <String, List<Tag>>{};
    for (final row in rows) {
      final link = row.readTable(_db.itemTags);
      final tag = row.readTable(_db.tags);
      (map[link.itemId] ??= []).add(
        Tag(id: tag.id, name: tag.name, color: tag.color),
      );
    }
    return map;
  }

  Future<Map<String, List<CatalogImage>>> _loadImages(List<String> ids) async {
    final rows = await (_db.select(_db.images)
          ..where((t) => t.itemId.isIn(ids))
          ..orderBy([(t) => OrderingTerm(expression: t.position)]))
        .get();
    final map = <String, List<CatalogImage>>{};
    for (final r in rows) {
      (map[r.itemId] ??= []).add(CatalogImage(id: r.id, position: r.position));
    }
    return map;
  }

  MediaEntry _rowToEntry(QueryRow r, List<Tag> tags, List<CatalogImage> images) {
    DateTime? ms(String col) {
      final v = r.readNullable<int>(col);
      return v == null ? null : DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
    }

    CatalogDate? cdate(String col, String precCol) {
      final value = ms(col);
      if (value == null) return null;
      final p = r.readNullable<String>(precCol);
      return CatalogDate(
        value,
        p == null ? DatePrecision.day : DatePrecision.fromCode(p),
      );
    }

    final ratingRaw = r.readNullable<int>('rating');
    final reasonRaw = r.readNullable<String>('unfinished_reason');

    return MediaEntry(
      id: r.read<String>('id'),
      title: r.read<String>('title'),
      status: WatchStatus.fromCode(r.read<String>('status')),
      mediaType: MediaType.fromCode(r.read<String>('media_type')),
      format: MediaFormat.fromCode(r.read<String>('format')),
      createdAt: ms('created_at')!,
      updatedAt: ms('updated_at')!,
      rating: ratingRaw == null ? null : Rating.clamp(ratingRaw),
      unfinishedReason:
          reasonRaw == null ? null : UnfinishedReason.fromCode(reasonRaw),
      note: r.readNullable<String>('note'),
      isFavorite: r.read<int>('is_favorite') == 1,
      rewatchCount: r.read<int>('event_count'),
      originalTitle: r.readNullable<String>('original_title'),
      year: r.readNullable<int>('year'),
      country: r.readNullable<String>('country'),
      currentSeason: r.readNullable<int>('current_season'),
      currentEpisode: r.readNullable<int>('current_episode'),
      totalSeasons: r.readNullable<int>('total_seasons'),
      totalEpisodes: r.readNullable<int>('total_episodes'),
      startedAt: cdate('started_at', 'started_at_prec'),
      lastActivityAt: cdate('last_activity_at', 'last_activity_at_prec'),
      finishedAt: cdate('finished_at', 'finished_at_prec'),
      tags: tags,
      images: images,
      deletedAt: ms('deleted_at'),
    );
  }

  // ─────────────────────────── query building ───────────────────────────

  (List<String>, List<Variable>) _buildWhere(MediaListQuery q) {
    final w = <String>[];
    final v = <Variable>[];

    w.add('c.domain = ?');
    v.add(Variable<String>(CatalogDomain.media.code));

    w.add(q.includeDeleted ? 'c.deleted_at IS NOT NULL' : 'c.deleted_at IS NULL');

    void inClause(String col, Iterable<String> codes) {
      final list = codes.toList();
      if (list.isEmpty) return;
      w.add('$col IN (${List.filled(list.length, '?').join(',')})');
      v.addAll(list.map((c) => Variable<String>(c)));
    }

    inClause('c.status', q.statuses.map((s) => s.code));
    inClause('m.media_type', q.mediaTypes.map((t) => t.code));
    inClause('m.format', q.formats.map((f) => f.code));
    inClause('c.unfinished_reason', q.unfinishedReasons.map((r) => r.code));
    inClause('m.country', q.countries);

    if (q.onlyFavorites) w.add('c.is_favorite = 1');
    if (q.onlyUnrated) w.add('c.rating IS NULL');
    if (q.ratingMin != null) {
      w.add('c.rating >= ?');
      v.add(Variable<int>(q.ratingMin!));
    }
    if (q.ratingMax != null) {
      w.add('c.rating <= ?');
      v.add(Variable<int>(q.ratingMax!));
    }

    if (q.tagIds.isNotEmpty) {
      final ph = List.filled(q.tagIds.length, '?').join(',');
      w.add('c.id IN (SELECT item_id FROM item_tags WHERE tag_id IN ($ph))');
      v.addAll(q.tagIds.map((t) => Variable<String>(t)));
    }

    final match = _ftsMatch(q.text);
    if (match != null) {
      w.add('c.id IN (SELECT item_id FROM catalog_fts WHERE catalog_fts MATCH ?)');
      v.add(Variable<String>(match));
    }

    return (w, v);
  }

  /// Превращает пользовательский ввод в безопасный FTS5-запрос с префиксами:
  /// «harry pot» -> «harry* pot*». Возвращает `null`, если искать нечего.
  String? _ftsMatch(String? text) {
    if (text == null) return null;
    final cleaned = text.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');
    final tokens = cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (tokens.isEmpty) return null;
    return tokens.map((t) => '$t*').join(' ');
  }

  String _buildOrderBy(MediaListQuery q) {
    final dir = q.sortDirection == SortDirection.asc ? 'ASC' : 'DESC';
    return switch (q.sortField) {
      // Неоценённые всегда в хвосте (§6.4).
      CatalogSortField.rating =>
        'ORDER BY c.rating IS NULL ASC, c.rating $dir, c.id ASC',
      CatalogSortField.title => 'ORDER BY c.title $dir, c.id ASC',
      CatalogSortField.year => 'ORDER BY m.year $dir, c.id ASC',
      CatalogSortField.createdAt => 'ORDER BY c.created_at $dir, c.id ASC',
      CatalogSortField.lastActivityAt =>
        'ORDER BY c.last_activity_at $dir, c.id ASC',
      CatalogSortField.finishedAt => 'ORDER BY c.finished_at $dir, c.id ASC',
      CatalogSortField.updatedAt => 'ORDER BY c.updated_at $dir, c.id ASC',
    };
  }
}

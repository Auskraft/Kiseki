import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/catalog/catalog_date.dart';
import '../../../core/catalog/catalog_domain.dart';
import '../../../core/catalog/catalog_image.dart';
import '../../../core/catalog/date_precision.dart';
import '../../../core/catalog/watch_status.dart';
import '../../../core/database/app_database.dart';
import '../domain/flavor_category.dart';
import '../domain/nicotine_type.dart';
import '../domain/vape_draft.dart';
import '../domain/vape_entry.dart';
import '../domain/vape_repository.dart';

/// Реализация [VapeRepository] поверх Drift. Ядро (`catalog_items`) + домен
/// (`vape_items`) пишутся в одной транзакции (порядок ядро→домен, §4.5).
class VapeRepositoryImpl implements VapeRepository {
  VapeRepositoryImpl(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  DateTime _now() => DateTime.now();

  static const _select =
      'SELECT c.*, v.brand, v.nicotine_type, v.nicotine_strength, '
      'v.flavor_category, v.flavor_description, v.sweetness, v.coolness, '
      'v.richness, v.can_rebuy, v.flavor_fades, v.damages_hardware '
      'FROM catalog_items c JOIN vape_items v ON v.item_id = c.id';

  @override
  Stream<List<VapeEntry>> watch() {
    return _db
        .customSelect(
          '$_select WHERE c.domain = ? AND c.deleted_at IS NULL '
          'ORDER BY c.created_at DESC, c.id ASC',
          variables: [Variable<String>(CatalogDomain.vape.code)],
          readsFrom: {_db.catalogItems, _db.vapeItems, _db.images},
        )
        .watch()
        .asyncMap(_attachAndMap);
  }

  @override
  Stream<VapeEntry?> watchById(String id) {
    return _db
        .customSelect(
          '$_select WHERE c.id = ?',
          variables: [Variable<String>(id)],
          readsFrom: {_db.catalogItems, _db.vapeItems, _db.images},
        )
        .watch()
        .asyncMap((rows) async {
      if (rows.isEmpty) return null;
      return (await _attachAndMap(rows)).first;
    });
  }

  @override
  Future<VapeEntry?> findById(String id) async {
    final rows = await _db.customSelect(
      '$_select WHERE c.id = ?',
      variables: [Variable<String>(id)],
    ).get();
    if (rows.isEmpty) return null;
    return (await _attachAndMap(rows)).first;
  }

  @override
  Future<String> create(VapeDraft d) async {
    final id = _uuid.v4();
    final now = _now();
    await _db.transaction(() async {
      await _db.into(_db.catalogItems).insert(_coreInsert(id, d, now));
      await _db.into(_db.vapeItems).insert(_vapeInsert(id, d));
      await _setCover(id, d.coverImageId, now);
    });
    return id;
  }

  @override
  Future<void> update(String id, VapeDraft d) async {
    final now = _now();
    await _db.transaction(() async {
      await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id)))
          .write(_coreUpdate(d, now));
      await (_db.update(_db.vapeItems)..where((t) => t.itemId.equals(id)))
          .write(_vapeUpdate(d));
      await _setCover(id, d.coverImageId, now);
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final now = _now();
    await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id))).write(
      CatalogItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  // ─────────────────────────── companions ───────────────────────────

  CatalogItemsCompanion _coreInsert(String id, VapeDraft d, DateTime now) {
    return CatalogItemsCompanion.insert(
      id: id,
      domain: CatalogDomain.vape,
      title: d.title,
      status: WatchStatus.plan, // ядровое поле не используется для vape
      createdAt: now,
      updatedAt: now,
      rating: Value(d.rating),
      note: Value(d.note),
      startedAt: Value(d.addedAt?.value),
      startedAtPrec: Value(d.addedAt?.precision),
    );
  }

  CatalogItemsCompanion _coreUpdate(VapeDraft d, DateTime now) {
    return CatalogItemsCompanion(
      title: Value(d.title),
      rating: Value(d.rating),
      note: Value(d.note),
      startedAt: Value(d.addedAt?.value),
      startedAtPrec: Value(d.addedAt?.precision),
      updatedAt: Value(now),
    );
  }

  VapeItemsCompanion _vapeInsert(String id, VapeDraft d) {
    return VapeItemsCompanion.insert(
      itemId: id,
      brand: d.brand,
      nicotineType: d.nicotineType,
      nicotineStrength: d.nicotineStrength,
      flavorCategory: Value(d.flavorCategory),
      flavorDescription: Value(d.flavorDescription),
      sweetness: Value(d.sweetness),
      coolness: Value(d.coolness),
      richness: Value(d.richness),
      canRebuy: Value(d.canRebuy),
      flavorFades: Value(d.flavorFades),
      damagesHardware: Value(d.damagesHardware),
    );
  }

  VapeItemsCompanion _vapeUpdate(VapeDraft d) {
    return VapeItemsCompanion(
      brand: Value(d.brand),
      nicotineType: Value(d.nicotineType),
      nicotineStrength: Value(d.nicotineStrength),
      flavorCategory: Value(d.flavorCategory),
      flavorDescription: Value(d.flavorDescription),
      sweetness: Value(d.sweetness),
      coolness: Value(d.coolness),
      richness: Value(d.richness),
      canRebuy: Value(d.canRebuy),
      flavorFades: Value(d.flavorFades),
      damagesHardware: Value(d.damagesHardware),
    );
  }

  /// Единственное фото (как обложка медиа): сносим строки `images` записи и
  /// ставим новую. Файлы пишет/чистит вызывающий слой (§7.3).
  Future<void> _setCover(String itemId, String? coverId, DateTime now) async {
    await (_db.delete(_db.images)..where((t) => t.itemId.equals(itemId))).go();
    if (coverId != null) {
      await _db.into(_db.images).insert(
            ImagesCompanion.insert(id: coverId, itemId: itemId, createdAt: now),
          );
    }
  }

  // ─────────────────────────── reading ───────────────────────────

  Future<List<VapeEntry>> _attachAndMap(List<QueryRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.read<String>('id')).toList();
    final imagesByItem = await _loadImages(ids);
    return rows
        .map((r) =>
            _rowToEntry(r, imagesByItem[r.read<String>('id')] ?? const []))
        .toList();
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

  VapeEntry _rowToEntry(QueryRow r, List<CatalogImage> images) {
    DateTime? ms(String col) {
      final v = r.readNullable<int>(col);
      return v == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
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

    final cat = r.readNullable<String>('flavor_category');
    return VapeEntry(
      id: r.read<String>('id'),
      title: r.read<String>('title'),
      brand: r.read<String>('brand'),
      nicotineType: NicotineType.fromCode(r.read<String>('nicotine_type')),
      nicotineStrength: r.read<String>('nicotine_strength'),
      createdAt: ms('created_at')!,
      updatedAt: ms('updated_at')!,
      rating: r.readNullable<int>('rating'),
      note: r.readNullable<String>('note'),
      addedAt: cdate('started_at', 'started_at_prec'),
      flavorCategory: cat == null ? null : FlavorCategory.fromCode(cat),
      flavorDescription: r.readNullable<String>('flavor_description'),
      sweetness: r.readNullable<int>('sweetness'),
      coolness: r.readNullable<int>('coolness'),
      richness: r.readNullable<int>('richness'),
      canRebuy: r.read<int>('can_rebuy') == 1,
      flavorFades: r.read<int>('flavor_fades') == 1,
      damagesHardware: r.read<int>('damages_hardware') == 1,
      images: images,
      deletedAt: ms('deleted_at'),
    );
  }
}

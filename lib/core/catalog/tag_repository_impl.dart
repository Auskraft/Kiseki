import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import 'tag.dart';
import 'tag_name.dart';
import 'tag_repository.dart';

/// Реализация [TagRepository] поверх Drift. Нормализация имени —
/// единственная точка истины (см. [normalizeTagName]).
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(
    this._db, {
    Uuid uuid = const Uuid(),
    DateTime Function()? clock,
  })  : _uuid = uuid,
        _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Future<List<Tag>> all() async {
    final rows = await (_db.select(_db.tags)
          ..orderBy([(t) => OrderingTerm(expression: t.nameNormalized)]))
        .get();
    return rows.map(_toTag).toList();
  }

  @override
  Stream<List<Tag>> watchAll() {
    return (_db.select(_db.tags)
          ..orderBy([(t) => OrderingTerm(expression: t.nameNormalized)]))
        .watch()
        .map((rows) => rows.map(_toTag).toList());
  }

  @override
  Stream<List<TagWithCount>> watchAllWithCounts() {
    // Считаем только живые карточки (не корзина).
    return _db
        .customSelect(
          'SELECT t.id, t.name, t.color, ('
          'SELECT COUNT(*) FROM item_tags it '
          'JOIN catalog_items c ON c.id = it.item_id '
          'WHERE it.tag_id = t.id AND c.deleted_at IS NULL'
          ') AS cnt '
          'FROM tags t ORDER BY t.name_normalized',
          readsFrom: {_db.tags, _db.itemTags, _db.catalogItems},
        )
        .watch()
        .map((rows) => rows
            .map((r) => TagWithCount(
                  Tag(
                    id: r.read<String>('id'),
                    name: r.read<String>('name'),
                    color: r.readNullable<String>('color'),
                  ),
                  r.read<int>('cnt'),
                ))
            .toList());
  }

  @override
  Future<Tag> ensure(String name, {String? color}) async {
    final normalized = normalizeTagName(name);
    final existing = await (_db.select(_db.tags)
          ..where((t) => t.nameNormalized.equals(normalized)))
        .getSingleOrNull();
    if (existing != null) return _toTag(existing);

    final id = _uuid.v4();
    final trimmed = name.trim();
    await _db.into(_db.tags).insert(TagsCompanion.insert(
          id: id,
          name: trimmed,
          nameNormalized: normalized,
          color: Value(color),
          createdAt: _now(),
        ));
    return Tag(id: id, name: trimmed, color: color);
  }

  @override
  Future<void> rename(String id, String newName) async {
    final trimmed = newName.trim();
    await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
      TagsCompanion(
        name: Value(trimmed),
        nameNormalized: Value(normalizeTagName(trimmed)),
      ),
    );
  }

  @override
  Future<void> recolor(String id, String? color) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(id)))
        .write(TagsCompanion(color: Value(color)));
  }

  @override
  Future<void> delete(String id) async {
    // CASCADE убирает связи item_tags.
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> merge(String sourceId, String targetId) async {
    if (sourceId == targetId) return;
    await _db.transaction(() async {
      // Переносим связи на целевой тег; дубли (item уже с целевым) игнорируем.
      await _db.customStatement(
        'INSERT OR IGNORE INTO item_tags(item_id, tag_id) '
        'SELECT item_id, ? FROM item_tags WHERE tag_id = ?',
        [targetId, sourceId],
      );
      await _db.customStatement(
        'DELETE FROM item_tags WHERE tag_id = ?',
        [sourceId],
      );
      await (_db.delete(_db.tags)..where((t) => t.id.equals(sourceId))).go();
    });
  }

  Tag _toTag(TagRow row) => Tag(id: row.id, name: row.name, color: row.color);
}

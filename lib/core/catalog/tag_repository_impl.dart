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

  Tag _toTag(TagRow row) => Tag(id: row.id, name: row.name, color: row.color);
}

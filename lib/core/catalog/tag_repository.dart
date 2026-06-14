import 'tag.dart';

/// Контракт работы с тегами (общий справочник). Реализация нормализует имя
/// (см. [normalizeTagName]) и держит UNIQUE по нормализованному имени.
abstract interface class TagRepository {
  Future<List<Tag>> all();

  Stream<List<Tag>> watchAll();

  /// Реактивный список тегов + число живых карточек с каждым (экран 05).
  Stream<List<TagWithCount>> watchAllWithCounts();

  /// Вернуть существующий тег по нормализованному имени или создать новый.
  Future<Tag> ensure(String name, {String? color});

  Future<void> rename(String id, String newName);

  Future<void> recolor(String id, String? color);

  Future<void> delete(String id);

  /// Сливает тег [sourceId] в [targetId]: переносит все связи на целевой тег
  /// (дубли игнорируются) и удаляет исходный. No-op, если id совпадают.
  Future<void> merge(String sourceId, String targetId);
}

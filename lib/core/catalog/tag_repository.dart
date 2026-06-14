import 'tag.dart';

/// Контракт работы с тегами (общий справочник). Реализация нормализует имя
/// (см. [normalizeTagName]) и держит UNIQUE по нормализованному имени.
abstract interface class TagRepository {
  Future<List<Tag>> all();

  Stream<List<Tag>> watchAll();

  /// Вернуть существующий тег по нормализованному имени или создать новый.
  Future<Tag> ensure(String name, {String? color});

  Future<void> rename(String id, String newName);

  Future<void> recolor(String id, String? color);

  Future<void> delete(String id);
}

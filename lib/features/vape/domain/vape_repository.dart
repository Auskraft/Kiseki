import 'vape_draft.dart';
import 'vape_entry.dart';

/// Контракт доступа к жидкостям для вейпа. Презентация держит ТОЛЬКО этот
/// интерфейс. Реактивность — через [watch]/[watchById].
abstract interface class VapeRepository {
  /// Реактивный список живых жидкостей (новые сверху).
  Stream<List<VapeEntry>> watch();

  /// Реактивная одиночная запись (для детали); `null` — отсутствует.
  Stream<VapeEntry?> watchById(String id);

  Future<VapeEntry?> findById(String id);

  /// Создаёт запись (UUID + created_at/updated_at). Возвращает id.
  Future<String> create(VapeDraft draft);

  /// Обновляет запись и двигает updated_at.
  Future<void> update(String id, VapeDraft draft);

  /// Мягкое удаление (ставит deleted_at — убирает из списка).
  Future<void> softDelete(String id);
}

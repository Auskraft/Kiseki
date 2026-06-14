import 'media_draft.dart';
import 'media_entry.dart';
import 'media_query.dart';

/// Контракт доступа к карточкам медиа. Bloc держит ТОЛЬКО этот интерфейс
/// (никогда не импортирует Drift напрямую). Реактивность — через [watch].
abstract interface class MediaRepository {
  /// Реактивный список по фильтру (пере-эмитит при изменении данных).
  Stream<List<MediaEntry>> watch(MediaListQuery query);

  Future<MediaEntry?> findById(String id);

  /// Создаёт карточку (генерит UUID, ставит created_at/updated_at).
  /// Возвращает id новой записи.
  Future<String> create(MediaDraft draft);

  /// Обновляет карточку и двигает updated_at (инвариант LWW).
  Future<void> update(String id, MediaDraft draft);

  /// Мягкое удаление (в корзину): ставит deleted_at.
  Future<void> softDelete(String id);

  /// Восстановление из корзины.
  Future<void> restore(String id);

  /// Окончательное удаление (вместе с доменной строкой и связями; файлы
  /// картинок чистятся вызывающим слоем после коммита).
  Future<void> purge(String id);
}

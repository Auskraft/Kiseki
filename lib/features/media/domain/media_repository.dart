import '../../../core/catalog/unfinished_reason.dart';
import '../../../core/catalog/watch_status.dart';
import 'media_draft.dart';
import 'media_entry.dart';
import 'media_query.dart';

/// Контракт доступа к карточкам медиа. Bloc держит ТОЛЬКО этот интерфейс
/// (никогда не импортирует Drift напрямую). Реактивность — через [watch].
abstract interface class MediaRepository {
  /// Реактивный список по фильтру (пере-эмитит при изменении данных).
  Stream<List<MediaEntry>> watch(MediaListQuery query);

  /// Реактивная одиночная карточка (для детали): пере-эмитит при изменении,
  /// `null` если запись отсутствует (включая физически удалённую).
  Stream<MediaEntry?> watchById(String id);

  Future<MediaEntry?> findById(String id);

  /// Создаёт карточку (генерит UUID, ставит created_at/updated_at).
  /// Возвращает id новой записи.
  Future<String> create(MediaDraft draft);

  /// Обновляет карточку и двигает updated_at (инвариант LWW).
  Future<void> update(String id, MediaDraft draft);

  /// Быстрая смена статуса (+ причина при `paused`/`dropped`). Двигает
  /// updated_at. Причина снимается вне паузы/заброса; «жду серии» — только
  /// при `paused` (ADR-08).
  Future<void> setStatus(String id, WatchStatus status,
      {UnfinishedReason? unfinishedReason});

  /// Переключение избранного. Двигает updated_at.
  Future<void> setFavorite(String id, bool isFavorite);

  /// +1 к счётчику пересмотров (`event_count`). Двигает updated_at.
  Future<void> incrementEventCount(String id);

  /// Мягкое удаление (в корзину): ставит deleted_at.
  Future<void> softDelete(String id);

  /// Восстановление из корзины.
  Future<void> restore(String id);

  /// Окончательное удаление (вместе с доменной строкой и связями; файлы
  /// картинок чистятся вызывающим слоем после коммита).
  Future<void> purge(String id);

  /// Окончательно удаляет ВСЕ карточки из корзины («Очистить корзину»).
  /// CASCADE убирает доменные строки/теги/картинки; FTS — триггером.
  Future<void> purgeAllTrashed();

  /// Все UUID картинок из БД (живые и в корзине) — для orphan-sweeper.
  Future<Set<String>> allImageIds();
}

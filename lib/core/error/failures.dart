/// Типизированные доменные ошибки (TECH_DESIGN §9). Каждая маппится на
/// конкретное действие в UI (повторить / освободить место / переподключить
/// Диск / восстановить из бэкапа). Наружу из data/слоёв летят именно они,
/// а не «голые» Exception.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class StorageFullFailure extends Failure {
  const StorageFullFailure([super.message = 'Недостаточно места на устройстве']);
}

class DbCorruptedFailure extends Failure {
  const DbCorruptedFailure([super.message = 'База данных повреждена']);
}

class FsFailure extends Failure {
  const FsFailure([super.message = 'Ошибка файловой системы']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет соединения']);
}

class AuthExpiredFailure extends Failure {
  const AuthExpiredFailure([super.message = 'Требуется повторная авторизация']);
}

class BackupCorruptedFailure extends Failure {
  const BackupCorruptedFailure([super.message = 'Архив бэкапа повреждён']);
}

class ImageDecodeFailure extends Failure {
  const ImageDecodeFailure([super.message = 'Не удалось обработать изображение']);
}

class ImageTooLargeFailure extends Failure {
  const ImageTooLargeFailure([super.message = 'Файл слишком большой']);
}

/// Статус просмотра/прогресса карточки (ядро картотеки).
///
/// `code` — стабильная строка, которая хранится в БД и бэкапе; она НЕ зависит
/// от имени enum-кейса в Dart, поэтому переименование кейса не ломает данные.
/// Канонический список — TECH_DESIGN §2.
enum WatchStatus {
  plan('plan'),
  watching('watching'),
  completed('completed'),
  paused('paused'),
  dropped('dropped');

  const WatchStatus(this.code);

  final String code;

  static WatchStatus fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown WatchStatus code: $code'),
      );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/features/media/presentation/pages/media_trash_page.dart';

void main() {
  test('retentionLabel: прошедшие и оставшиеся дни', () {
    final deleted = DateTime.utc(2026, 6, 1);
    expect(retentionLabel(deleted, DateTime.utc(2026, 6, 1)),
        'удалено сегодня · через 30 дн.');
    expect(retentionLabel(deleted, DateTime.utc(2026, 6, 4)),
        'удалено 3 дн. назад · через 27 дн.');
  });

  test('retentionLabel: остаток не уходит в минус после срока', () {
    final deleted = DateTime.utc(2026, 6, 1);
    expect(retentionLabel(deleted, DateTime.utc(2026, 7, 20)),
        contains('через 0 дн.'));
  });
}

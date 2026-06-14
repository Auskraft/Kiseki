import 'package:flutter/material.dart';

import '../catalog/unfinished_reason.dart';
import '../catalog/watch_status.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Подпись причины «не досмотрел» (общая для редактора и детали).
String reasonLabel(UnfinishedReason reason) => switch (reason) {
      UnfinishedReason.waitingEpisodes => 'Жду серии',
      UnfinishedReason.lostQuality => 'Скатился',
      UnfinishedReason.notForMe => 'Не зашло',
      UnfinishedReason.noTime => 'Нет времени',
      UnfinishedReason.other => 'Другое',
    };

/// Иконка и подпись статуса (смысл передаётся не только цветом, a11y).
/// Особый случай — «жду серии»: песочные часы, подпись «Жду серии»
/// (визуально отделено от «Заброшено»).
abstract final class StatusVisual {
  static IconData icon(WatchStatus status, {bool waiting = false}) {
    if (waiting) return Icons.hourglass_bottom_rounded;
    return switch (status) {
      WatchStatus.plan => Icons.schedule_rounded,
      WatchStatus.watching => Icons.play_arrow_rounded,
      WatchStatus.completed => Icons.check_rounded,
      WatchStatus.paused => Icons.pause_rounded,
      WatchStatus.dropped => Icons.inventory_2_outlined,
    };
  }

  static String label(WatchStatus status, {bool waiting = false}) {
    if (waiting) return 'Жду серии';
    return switch (status) {
      WatchStatus.plan => 'В планах',
      WatchStatus.watching => 'Смотрю',
      WatchStatus.completed => 'Просмотрено',
      WatchStatus.paused => 'На паузе',
      WatchStatus.dropped => 'Заброшено',
    };
  }
}

/// Чип статуса: тинт-контейнер + иконка + подпись. Не сжимается (nowrap).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.waiting = false});

  final WatchStatus status;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = tk.statusColor(waiting ? WatchStatus.paused : status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tk.tint(color, 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(StatusVisual.icon(status, waiting: waiting), size: 13 * uiScale, color: color),
          const SizedBox(width: 4),
          Text(
            StatusVisual.label(status, waiting: waiting),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Квадратный значок статуса для угла постера (белая иконка на затемнённом
/// статус-цвете).
class StatusSquare extends StatelessWidget {
  const StatusSquare({super.key, required this.status, this.waiting = false, this.size = 22});

  final WatchStatus status;
  final bool waiting;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = tk.statusColor(waiting ? WatchStatus.paused : status);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color.alphaBlend(Colors.black.withValues(alpha: 0.12), color),
        borderRadius: BorderRadius.circular(AppRadii.xs - 1),
      ),
      child: Icon(
        StatusVisual.icon(status, waiting: waiting),
        size: size * 0.62,
        color: Colors.white,
      ),
    );
  }
}

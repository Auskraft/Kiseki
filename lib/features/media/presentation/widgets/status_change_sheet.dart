import 'package:flutter/material.dart';

import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/status_visuals.dart';

/// Результат выбора в листе статуса.
typedef StatusChoice = ({WatchStatus status, UnfinishedReason? reason});

/// Боттомшит быстрой смены статуса. Для `paused`/`dropped` доспрашивает
/// причину (TECH_DESIGN §6.3); «жду серии» — только `paused` + `episodic`.
/// Возвращает выбор или `null`, если отменили.
Future<StatusChoice?> showStatusSheet(
  BuildContext context, {
  required WatchStatus current,
  UnfinishedReason? currentReason,
  required bool episodic,
}) {
  return showModalBottomSheet<StatusChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _StatusSheet(
      current: current,
      currentReason: currentReason,
      episodic: episodic,
    ),
  );
}

class _StatusSheet extends StatefulWidget {
  const _StatusSheet({
    required this.current,
    required this.currentReason,
    required this.episodic,
  });

  final WatchStatus current;
  final UnfinishedReason? currentReason;
  final bool episodic;

  @override
  State<_StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<_StatusSheet> {
  late WatchStatus _status = widget.current;
  late UnfinishedReason? _reason = widget.currentReason;

  bool get _needsReason =>
      _status == WatchStatus.paused || _status == WatchStatus.dropped;

  bool get _canOfferWaiting =>
      _status == WatchStatus.paused && widget.episodic;

  void _pick(WatchStatus s) {
    // Статусы без причины применяются сразу; пауза/заброс ждут доспроса.
    if (s != WatchStatus.paused && s != WatchStatus.dropped) {
      Navigator.pop(context, (status: s, reason: null));
      return;
    }
    setState(() {
      _status = s;
      if (_reason == UnfinishedReason.waitingEpisodes &&
          s != WatchStatus.paused) {
        _reason = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tk.surface3,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Сменить статус', style: text.titleMedium),
          ),
          const SizedBox(height: 12),
          for (final s in WatchStatus.values)
            _StatusRow(
              status: s,
              selected: _status == s,
              onTap: () => _pick(s),
            ),
          if (_needsReason) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Причина', style: text.labelMedium),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final r in UnfinishedReason.values)
                  if (r != UnfinishedReason.waitingEpisodes || _canOfferWaiting)
                    _ReasonChip(
                      reason: r,
                      selected: _reason == r,
                      onTap: () => setState(
                          () => _reason = _reason == r ? null : r),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.pop(context, (status: _status, reason: _reason)),
                child: const Text('Применить'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final WatchStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = tk.statusColor(status);
    return Material(
      color: selected ? tk.tint(color, 0.14) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Row(
            children: [
              StatusSquare(status: status, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  StatusVisual.label(status),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? color : tk.onBg,
                      ),
                ),
              ),
              if (selected) Icon(Icons.check_rounded, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final UnfinishedReason reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = tk.statusColor(WatchStatus.paused);
    return Material(
      color: selected ? tk.tint(color, 0.18) : tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? color : tk.outlineSoft,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reason == UnfinishedReason.waitingEpisodes) ...[
                Icon(Icons.hourglass_bottom_rounded,
                    size: 13 * uiScale, color: selected ? color : tk.onMuted),
                const SizedBox(width: 5),
              ],
              Text(
                reasonLabel(reason),
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? color : tk.onMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

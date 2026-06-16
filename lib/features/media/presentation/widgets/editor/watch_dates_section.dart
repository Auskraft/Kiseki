import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/catalog/catalog_date.dart';
import '../../../../../core/catalog/date_precision.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/kiseki_tokens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../../../core/ui/catalog_date_format.dart';

const List<String> _months = [
  'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', //
  'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
];

const int _minYear = 1888; // нижняя граница из CHECK схемы

/// Секция «Даты просмотров»: 3 прямоугольника-блока (Начало/Окончание/
/// Завершение), дата в каждом выбирается барабаном месяц+год. Плюс счётчик
/// пересмотров с цветовой маркировкой (значение `event_count` ядра).
class WatchDatesSection extends StatelessWidget {
  const WatchDatesSection({
    super.key,
    required this.startedAt,
    required this.onStarted,
    required this.lastActivityAt,
    required this.onLastActivity,
    required this.finishedAt,
    required this.onFinished,
    required this.rewatchCount,
    required this.onRewatchChanged,
  });

  final CatalogDate? startedAt;
  final ValueChanged<CatalogDate?> onStarted;
  final CatalogDate? lastActivityAt;
  final ValueChanged<CatalogDate?> onLastActivity;
  final CatalogDate? finishedAt;
  final ValueChanged<CatalogDate?> onFinished;
  final int rewatchCount;
  final ValueChanged<int> onRewatchChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Даты просмотров',
          style: TextStyle(
            fontSize: 12.5 * uiScale,
            fontWeight: FontWeight.w700,
            color: tk.onMuted,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _DateBlock(
                  label: 'Начало', value: startedAt, onChanged: onStarted),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DateBlock(
                  label: 'Окончание',
                  value: lastActivityAt,
                  onChanged: onLastActivity),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DateBlock(
                  label: 'Завершение',
                  value: finishedAt,
                  onChanged: onFinished),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _RewatchCounter(count: rewatchCount, onChanged: onRewatchChanged),
      ],
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final CatalogDate? value;
  final ValueChanged<CatalogDate?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final has = value != null;
    return Material(
      color: tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: () => _pickMonthYear(context, value, onChanged),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          height: 76,
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: tk.onMuted,
                ),
              ),
              const Spacer(),
              if (has)
                Text(
                  formatCatalogDate(value!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5 * uiScale,
                    fontWeight: FontWeight.w700,
                    color: tk.onBg,
                    height: 1.15,
                  ),
                )
              else
                Icon(Icons.add_rounded, size: 20, color: tk.onFaint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Барабан «месяц + год» → [CatalogDate] с точностью «месяц». «Очистить» → null.
Future<void> _pickMonthYear(
  BuildContext context,
  CatalogDate? initial,
  ValueChanged<CatalogDate?> onChanged,
) async {
  final tk = context.tokens;
  final now = DateTime.now();
  final maxYear = math.max(now.year + 2, initial?.value.year ?? 0);
  final years = [for (var y = maxYear; y >= _minYear; y--) y];

  var monthIndex = (initial?.value.month ?? now.month) - 1;
  var yearIndex = years.indexOf(initial?.value.year ?? now.year);
  if (yearIndex < 0) yearIndex = 0;

  final result = await showModalBottomSheet<({CatalogDate? date})>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      var mTemp = monthIndex;
      var yTemp = yearIndex;
      return Container(
        decoration: BoxDecoration(
          color: tk.surface2,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 2),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tk.surface3,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, (date: null)),
                    child:
                        Text('Очистить', style: TextStyle(color: tk.onMuted)),
                  ),
                  Text('Месяц и год',
                      style: TextStyle(
                        fontSize: 14 * uiScale,
                        fontWeight: FontWeight.w700,
                        color: tk.onBg,
                      )),
                  TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      (
                        // normalizeCatalogDate строит дату в UTC (как везде в
                        // приложении) — иначе локальный DateTime в +TZ при
                        // round-trip съезжает на месяц назад.
                        date: normalizeCatalogDate(
                          DateTime(years[yTemp], mTemp + 1, 1),
                          DatePrecision.month,
                        )
                      ),
                    ),
                    child: Text('Готово',
                        style: TextStyle(
                            color: tk.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 190,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CupertinoPicker(
                      scrollController:
                          FixedExtentScrollController(initialItem: monthIndex),
                      itemExtent: 38,
                      backgroundColor: Colors.transparent,
                      selectionOverlay: _overlay(tk),
                      onSelectedItemChanged: (i) {
                        HapticFeedback.selectionClick();
                        mTemp = i;
                      },
                      children: [
                        for (final m in _months)
                          Center(
                            child: Text(m,
                                style: TextStyle(
                                    fontSize: 17 * uiScale, color: tk.onBg)),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CupertinoPicker(
                      scrollController:
                          FixedExtentScrollController(initialItem: yearIndex),
                      itemExtent: 38,
                      backgroundColor: Colors.transparent,
                      selectionOverlay: _overlay(tk),
                      onSelectedItemChanged: (i) {
                        HapticFeedback.selectionClick();
                        yTemp = i;
                      },
                      children: [
                        for (final y in years)
                          Center(
                            child: Text('$y',
                                style: TextStyle(
                                    fontSize: 17 * uiScale, color: tk.onBg)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  if (result != null) onChanged(result.date);
}

Widget _overlay(KisekiTokens tk) => Container(
      decoration: BoxDecoration(
        border:
            Border.symmetric(horizontal: BorderSide(color: tk.outlineSoft)),
      ),
    );

/// Счётчик пересмотров: «− N +» с цветовой маркировкой (чем больше — теплее).
class _RewatchCounter extends StatelessWidget {
  const _RewatchCounter({required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  Color _color(KisekiTokens tk) {
    if (count <= 0) return tk.onFaint;
    if (count == 1) return tk.secondary;
    if (count <= 3) return tk.primary;
    if (count <= 5) return const Color(0xFFE0A03A);
    return tk.favorite;
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = _color(tk);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: tk.outlineSoft),
      ),
      // mainAxisSize.min — блок по контенту (узкий), не на всю ширину.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Пересмотры',
            style: TextStyle(
              fontSize: 13 * uiScale,
              fontWeight: FontWeight.w600,
              color: tk.onBg,
            ),
          ),
          const SizedBox(width: 10),
          _StepBtn(
            icon: Icons.remove_rounded,
            onTap: count > 0 ? () => onChanged(count - 1) : null,
          ),
          SizedBox(
            width: 34,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 19 * uiScale,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              textAlign: TextAlign.center,
              child: Text('$count', textAlign: TextAlign.center),
            ),
          ),
          _StepBtn(
            icon: Icons.add_rounded,
            onTap: () => onChanged(count + 1),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon,
              size: 22, color: enabled ? tk.primary : tk.onFaint),
        ),
      ),
    );
  }
}

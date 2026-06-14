import 'package:flutter/material.dart';

import '../../../../../core/catalog/catalog_date.dart';
import '../../../../../core/catalog/date_precision.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import 'editor_primitives.dart';

const _monthsNom = <String>[
  'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
  'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь',
];

/// Человекочитаемая дата по её точности (TECH_DESIGN §6.6):
/// `day` → «12.03.2024», `month` → «март 2024», `year` → «2024».
String formatCatalogDate(CatalogDate date) {
  final d = date.value;
  return switch (date.precision) {
    DatePrecision.day =>
      '${_two(d.day)}.${_two(d.month)}.${d.year}',
    DatePrecision.month => '${_monthsNom[d.month - 1]} ${d.year}',
    DatePrecision.year => '${d.year}',
  };
}

/// Нормализует дату к точности: год → 1 января, месяц → 1-е число (§6.6).
/// Хранится в UTC (модель — Unix-мс UTC).
CatalogDate normalizeCatalogDate(DateTime d, DatePrecision p) {
  return switch (p) {
    DatePrecision.day => CatalogDate(DateTime.utc(d.year, d.month, d.day), p),
    DatePrecision.month => CatalogDate(DateTime.utc(d.year, d.month), p),
    DatePrecision.year => CatalogDate(DateTime.utc(d.year), p),
  };
}

String _two(int v) => v.toString().padLeft(2, '0');

/// Поле пользовательской даты: переключатель гранулярности (День/Месяц/Год),
/// само значение (тап — пикер) и шорткаты «Сегодня» / «Не помню».
class CatalogDateField extends StatelessWidget {
  const CatalogDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final CatalogDate? value;
  final ValueChanged<CatalogDate?> onChanged;

  DatePrecision get _precision => value?.precision ?? DatePrecision.day;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value?.value ?? now,
      firstDate: DateTime(1888),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) onChanged(normalizeCatalogDate(picked, _precision));
  }

  void _setPrecision(DatePrecision p) {
    final v = value;
    onChanged(v == null ? null : normalizeCatalogDate(v.value, p));
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorLabel('$label · гранулярность'),
        Row(
          children: [
            _GranularityTrack(
              precision: _precision,
              onChanged: _setPrecision,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Material(
                color: tk.surface,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: InkWell(
                  onTap: () => _pick(context),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: tk.outlineSoft),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 15, color: tk.onFaint),
                        const SizedBox(width: 8),
                        Text(
                          value == null ? 'не указано' : formatCatalogDate(value!),
                          style: TextStyle(
                            fontSize: 13.5 * uiScale,
                            fontWeight: FontWeight.w600,
                            color: value == null ? tk.onFaint : tk.onBg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Shortcut(
              label: 'Сегодня',
              accent: true,
              onTap: () => onChanged(
                  normalizeCatalogDate(DateTime.now(), _precision)),
            ),
            const SizedBox(width: 7),
            _Shortcut(
              label: 'Не помню',
              accent: false,
              onTap: () => onChanged(null),
            ),
          ],
        ),
      ],
    );
  }
}

class _GranularityTrack extends StatelessWidget {
  const _GranularityTrack({required this.precision, required this.onChanged});

  final DatePrecision precision;
  final ValueChanged<DatePrecision> onChanged;

  static const _opts = <(DatePrecision, String)>[
    (DatePrecision.day, 'День'),
    (DatePrecision.month, 'Месяц'),
    (DatePrecision.year, 'Год'),
  ];

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: tk.surface3,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, label) in _opts)
            GestureDetector(
              onTap: () => onChanged(value),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: value == precision ? tk.surface2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12 * uiScale,
                    fontWeight:
                        value == precision ? FontWeight.w700 : FontWeight.w600,
                    color: value == precision ? tk.onBg : tk.onMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: accent ? tk.tint(tk.primary, 0.12) : tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: accent ? null : Border.all(color: tk.outlineSoft),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5 * uiScale,
              fontWeight: accent ? FontWeight.w700 : FontWeight.w600,
              color: accent ? tk.primary : tk.onMuted,
            ),
          ),
        ),
      ),
    );
  }
}

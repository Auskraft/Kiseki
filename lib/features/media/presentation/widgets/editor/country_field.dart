import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';

/// Курированный список стран, релевантных домену «медиа» (дорамы/аниме/кино).
/// Ключ — ISO 3166-1 alpha-2 (хранимый код), значение — русское название.
const Map<String, String> kCountries = {
  'KR': 'Корея',
  'JP': 'Япония',
  'CN': 'Китай',
  'TH': 'Таиланд',
  'US': 'США',
  'GB': 'Великобритания',
  'FR': 'Франция',
  'DE': 'Германия',
  'ES': 'Испания',
  'IT': 'Италия',
  'RU': 'Россия',
  'IN': 'Индия',
  'TR': 'Турция',
  'TW': 'Тайвань',
  'HK': 'Гонконг',
};

/// Название страны по коду; если код не из списка — показываем сам код.
String countryName(String code) => kCountries[code] ?? code;

/// Поле выбора страны (alpha-2). Тап открывает список; «Не указана» сбрасывает.
class CountryField extends StatelessWidget {
  const CountryField({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final tk = context.tokens;
    final selected = await showModalBottomSheet<({String? code})>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: tk.surface2,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        padding: EdgeInsets.only(
          top: 10,
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tk.surface3,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _CountryTile(
                    label: 'Не указана',
                    selected: value == null,
                    muted: true,
                    onTap: () => Navigator.pop(context, (code: null)),
                  ),
                  for (final entry in kCountries.entries)
                    _CountryTile(
                      label: entry.value,
                      selected: value == entry.key,
                      muted: false,
                      onTap: () => Navigator.pop(context, (code: entry.key)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) onChanged(selected.code);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final hasValue = value != null;
    return Material(
      color: tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Row(
            children: [
              Icon(Icons.public, size: 16, color: tk.onFaint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasValue ? countryName(value!) : 'Страна',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * uiScale,
                    fontWeight: FontWeight.w500,
                    color: hasValue ? tk.onBg : tk.onFaint,
                  ),
                ),
              ),
              Icon(Icons.expand_more_rounded, size: 18, color: tk.onFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.label,
    required this.selected,
    required this.muted,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14 * uiScale,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: muted ? tk.onMuted : tk.onBg,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 18, color: tk.primary),
          ],
        ),
      ),
    );
  }
}

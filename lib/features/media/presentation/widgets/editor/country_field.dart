import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';

/// Страны для домена «медиа» (кино/сериалы/дорамы/аниме). Ключ — ISO 3166-1
/// alpha-2 (хранимый код), значение — русское название. Список расширенный —
/// в пикере есть поиск; флаг рисуется из кода ([countryFlag]).
const Map<String, String> kCountries = {
  // Азия (дорамы/аниме — вперёд)
  'KR': 'Корея',
  'JP': 'Япония',
  'CN': 'Китай',
  'TH': 'Таиланд',
  'TW': 'Тайвань',
  'HK': 'Гонконг',
  'IN': 'Индия',
  'ID': 'Индонезия',
  'PH': 'Филиппины',
  'VN': 'Вьетнам',
  'MY': 'Малайзия',
  'SG': 'Сингапур',
  // Запад
  'US': 'США',
  'GB': 'Великобритания',
  'FR': 'Франция',
  'DE': 'Германия',
  'ES': 'Испания',
  'IT': 'Италия',
  'CA': 'Канада',
  'AU': 'Австралия',
  'NZ': 'Новая Зеландия',
  'IE': 'Ирландия',
  // Европа
  'RU': 'Россия',
  'UA': 'Украина',
  'PL': 'Польша',
  'CZ': 'Чехия',
  'SE': 'Швеция',
  'NO': 'Норвегия',
  'DK': 'Дания',
  'FI': 'Финляндия',
  'NL': 'Нидерланды',
  'BE': 'Бельгия',
  'AT': 'Австрия',
  'CH': 'Швейцария',
  'PT': 'Португалия',
  'GR': 'Греция',
  'HU': 'Венгрия',
  'RO': 'Румыния',
  'IS': 'Исландия',
  'TR': 'Турция',
  // Америка
  'BR': 'Бразилия',
  'MX': 'Мексика',
  'AR': 'Аргентина',
  'CO': 'Колумбия',
  'CL': 'Чили',
  // Ближний Восток / Африка / СНГ
  'IR': 'Иран',
  'IL': 'Израиль',
  'AE': 'ОАЭ',
  'EG': 'Египет',
  'ZA': 'ЮАР',
  'KZ': 'Казахстан',
  'GE': 'Грузия',
  'AM': 'Армения',
};

/// Компактный набор для чипов фильтра (полный список ищется в пикере редактора).
const List<String> kCommonCountryCodes = [
  'KR', 'JP', 'CN', 'TH', 'US', 'GB', 'FR', 'DE', 'ES', 'IT', 'RU', 'IN', //
  'TR', 'TW', 'HK',
];

/// Название страны по коду; если код не из списка — показываем сам код.
String countryName(String code) => kCountries[code] ?? code;

/// Эмодзи-флаг из ISO alpha-2 (regional indicator symbols). Для некорректного
/// кода — нейтральный флаг.
String countryFlag(String code) {
  if (code.length != 2) return '🏳️';
  final up = code.toUpperCase();
  final a = up.codeUnitAt(0);
  final b = up.codeUnitAt(1);
  if (a < 0x41 || a > 0x5A || b < 0x41 || b > 0x5A) return '🏳️';
  return String.fromCharCode(0x1F1E6 + (a - 0x41)) +
      String.fromCharCode(0x1F1E6 + (b - 0x41));
}

/// Поле выбора страны (alpha-2). Тап открывает список с поиском и флагами;
/// «Не указана» сбрасывает. В закрытом виде показывает флаг + название.
class CountryField extends StatelessWidget {
  const CountryField({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final selected = await showModalBottomSheet<({String? code})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(selected: value),
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
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Row(
            children: [
              if (hasValue)
                Text(countryFlag(value!), style: const TextStyle(fontSize: 16))
              else
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

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selected});

  final String? selected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final q = _query.trim().toLowerCase();
    final entries = kCountries.entries.where((e) {
      if (q.isEmpty) return true;
      return e.value.toLowerCase().contains(q) || e.key.toLowerCase().contains(q);
    }).toList();
    final maxH = MediaQuery.sizeOf(context).height * 0.72;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: tk.surface2,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tk.surface3,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(fontSize: 14 * uiScale, color: tk.onBg),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: tk.surface,
                  hintText: 'Поиск страны',
                  hintStyle: TextStyle(color: tk.onFaint),
                  prefixIcon:
                      Icon(Icons.search_rounded, size: 18, color: tk.onFaint),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: BorderSide(color: tk.outlineSoft),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: BorderSide(color: tk.outlineSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: BorderSide(color: tk.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (q.isEmpty)
                    _CountryTile(
                      flag: null,
                      label: 'Не указана',
                      selected: widget.selected == null,
                      muted: true,
                      onTap: () => Navigator.pop(context, (code: null)),
                    ),
                  for (final entry in entries)
                    _CountryTile(
                      flag: countryFlag(entry.key),
                      label: entry.value,
                      selected: widget.selected == entry.key,
                      muted: false,
                      onTap: () => Navigator.pop(context, (code: entry.key)),
                    ),
                  if (entries.isEmpty && q.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Ничего не найдено',
                            style: TextStyle(color: tk.onMuted)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.muted,
    required this.onTap,
  });

  final String? flag;
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
            if (flag != null) ...[
              Text(flag!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
            ],
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
            if (selected) Icon(Icons.check_rounded, size: 18, color: tk.primary),
          ],
        ),
      ),
    );
  }
}

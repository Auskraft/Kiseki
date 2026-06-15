import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';

const int _minYear = 1888; // нижняя граница из CHECK схемы (TECH_DESIGN §4.2)

/// Поле года — открывает «барабан» (CupertinoPicker) вместо ручного ввода.
/// `value == null` → подпись «Год»; в пикере есть «Очистить».
class YearField extends StatelessWidget {
  const YearField({super.key, required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final tk = context.tokens;
    final nowYear = DateTime.now().year;
    // Верх — небольшой запас в будущее, но не меньше уже сохранённого значения.
    final maxYear = math.max(nowYear + 2, value ?? 0);
    final years = [for (var y = maxYear; y >= _minYear; y--) y];
    var index = years.indexOf(value ?? nowYear);
    if (index < 0) index = 0;

    final result = await showModalBottomSheet<({int? year})>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        var temp = index;
        return Container(
          decoration: BoxDecoration(
            color: tk.surface2,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
          ),
          padding:
              EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 6),
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
                      onPressed: () => Navigator.pop(context, (year: null)),
                      child:
                          Text('Очистить', style: TextStyle(color: tk.onMuted)),
                    ),
                    Text('Год',
                        style: TextStyle(
                          fontSize: 14 * uiScale,
                          fontWeight: FontWeight.w700,
                          color: tk.onBg,
                        )),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, (year: years[temp])),
                      child: Text('Готово',
                          style: TextStyle(
                              color: tk.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: index),
                  itemExtent: 38,
                  backgroundColor: Colors.transparent,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: tk.outlineSoft),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (i) {
                    HapticFeedback.selectionClick();
                    temp = i;
                  },
                  children: [
                    for (final y in years)
                      Center(
                        child: Text('$y',
                            style: TextStyle(
                                fontSize: 18 * uiScale, color: tk.onBg)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result != null) onChanged(result.year);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final has = value != null;
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
              Expanded(
                child: Text(
                  has ? '$value' : 'Год',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * uiScale,
                    fontWeight: FontWeight.w500,
                    color: has ? tk.onBg : tk.onFaint,
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

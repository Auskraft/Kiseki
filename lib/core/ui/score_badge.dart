import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Подпись диапазона оценки (для детали: «Отличная»). Дублирует смысл цвета.
String scoreLabel(int value) {
  if (value < 40) return 'Слабая';
  if (value < 60) return 'Средняя';
  if (value < 75) return 'Хорошая';
  if (value < 90) return 'Отличная';
  return 'Шедевр';
}

/// Бейдж оценки 0–100. Цвет по диапазону, число всегда текстом (a11y).
/// `null` = «не оценено» -> «—» (не «0»).
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    super.key,
    required this.value,
    this.showMax = false,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  final int? value;
  final bool showMax;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    if (value == null) {
      return _pill(
        background: tk.surface3,
        child: Text(
          '—',
          style: GoogleFonts.onest(
            fontSize: fontSize * uiScale,
            fontWeight: FontWeight.w700,
            color: tk.onFaint,
          ),
        ),
      );
    }

    final color = tk.scoreColor(value!);
    return _pill(
      background: tk.tint(color, 0.16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$value',
            style: GoogleFonts.onest(
              fontSize: fontSize * uiScale,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (showMax)
            Text(
              ' / 100',
              style: GoogleFonts.onest(
                fontSize: fontSize * 0.72 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onFaint,
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill({required Color background, required Widget child}) => DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Padding(padding: padding, child: child),
      );
}

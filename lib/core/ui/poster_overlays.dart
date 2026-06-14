import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Бейдж оценки поверх постера — «стекло» (тёмный полупрозрачный фон + blur),
/// число в цвете оценки. `null` -> «—» белым.
class PosterScoreBadge extends StatelessWidget {
  const PosterScoreBadge({super.key, required this.value, this.fontSize = 12});

  final int? value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = value == null ? Colors.white : tk.scoreColor(value!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          color: Colors.black.withValues(alpha: 0.42),
          child: Text(
            value == null ? '—' : '$value',
            style: GoogleFonts.onest(
              fontSize: fontSize * uiScale,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// Сердечко избранного на тёмном круге.
class FavHeart extends StatelessWidget {
  const FavHeart({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size * uiScale;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.favorite, size: s * 0.56, color: const Color(0xFFFF7BA3)),
    );
  }
}

/// Тонкая полоса прогресса серий в нижней части постера.
class PosterProgressBar extends StatelessWidget {
  const PosterProgressBar({super.key, required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.32),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction.clamp(0.0, 1.0),
            child: ColoredBox(color: color),
          ),
        ),
      ),
    );
  }
}

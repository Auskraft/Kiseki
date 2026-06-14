import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../domain/media_type.dart';

/// Плейсхолдер обложки: градиент по hue типа медиа + крупная фоновая буква
/// (как в дизайне). Используется, пока нет файла картинки или он потерян.
class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({
    super.key,
    required this.type,
    required this.title,
    this.radius = AppRadii.md,
    this.letterSize = 64,
  });

  final MediaType type;
  final String title;
  final double radius;
  final double letterSize;

  @override
  Widget build(BuildContext context) {
    final seed = _seed(type);
    final hsl = HSLColor.fromColor(seed);
    final top = hsl
        .withLightness((hsl.lightness + 0.07).clamp(0.0, 1.0))
        .toColor();
    final bottom = hsl
        .withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
        .toColor();
    final t = title.trim();
    final letter = t.isEmpty ? '?' : t.characters.first.toUpperCase();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [top, bottom],
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: GoogleFonts.lora(
              fontSize: letterSize,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
        ),
      ),
    );
  }

  Color _seed(MediaType type) => switch (type) {
        MediaType.movie => const Color(0xFF4E63B6),
        MediaType.series => const Color(0xFF3E8E9E),
        MediaType.drama => const Color(0xFFB85C82),
        MediaType.anime => const Color(0xFF8A5FC0),
      };
}

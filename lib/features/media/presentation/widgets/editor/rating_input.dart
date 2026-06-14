import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import 'editor_primitives.dart';

/// Ввод оценки 0–100: число в цвете диапазона + слайдер (зона ≥48 dp).
/// `null` = «не оценено» («—»); первое касание ставит значение, «×» — сбрасывает.
class RatingInput extends StatelessWidget {
  const RatingInput({super.key, required this.value, required this.onChanged});

  /// 0–100 или `null` («без оценки»).
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final rated = value != null;
    final color = rated ? tk.scoreColor(value!) : tk.onFaint;

    return EditorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Оценка',
                style: TextStyle(
                  fontSize: 12.5 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: tk.onMuted,
                ),
              ),
              const Spacer(),
              if (rated)
                _ClearButton(onTap: () => onChanged(null))
              else
                Text(
                  'без оценки',
                  style: TextStyle(
                    fontSize: 11.5 * uiScale,
                    fontWeight: FontWeight.w600,
                    color: tk.onFaint,
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                width: 54,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tk.surface3,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  rated ? '${value!}' : '—',
                  style: GoogleFonts.onest(
                    fontSize: 17 * uiScale,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/100',
                style: TextStyle(
                  fontSize: 13 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: tk.onFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: tk.surface3,
              thumbColor: tk.surface2,
              overlayColor: color.withValues(alpha: 0.14),
              thumbShape: _RingThumb(color: color),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: (value ?? 0).toDouble(),
              max: 100,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close_rounded, size: 13, color: tk.onFaint),
            const SizedBox(width: 3),
            Text(
              'убрать',
              style: TextStyle(
                fontSize: 11.5 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Бегунок-кольцо: surface-заливка + 2 px обводка цветом оценки (как в макете).
class _RingThumb extends SliderComponentShape {
  const _RingThumb({required this.color});

  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(11);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      11,
      Paint()..color = sliderTheme.thumbColor ?? Colors.white,
    );
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

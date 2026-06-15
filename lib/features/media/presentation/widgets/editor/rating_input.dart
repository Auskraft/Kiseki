import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import 'editor_primitives.dart';

/// Ввод оценки. Хранится 0–100, показывается дробной /10 (8.4). Слайдер —
/// спектр red→green (10 градаций) с тактильным откликом и плавной сменой цвета.
/// `null` = «не оценено» («—»); первое касание ставит значение, «×» — сбрасывает.
class RatingInput extends StatefulWidget {
  const RatingInput({super.key, required this.value, required this.onChanged});

  /// 0–100 или `null` («без оценки»).
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  int _lastTick = 0;

  void _onSlide(double v) {
    final nv = v.round();
    if (nv != _lastTick) {
      HapticFeedback.selectionClick();
      _lastTick = nv;
    }
    widget.onChanged(nv);
  }

  void _clear() {
    _lastTick = 0;
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final value = widget.value;
    final rated = value != null;
    final color = rated ? tk.scoreColor(value) : tk.onFaint;
    final ten = rated ? (value / 10).toStringAsFixed(1) : '—';

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
                _ClearButton(onTap: _clear)
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rated ? tk.tint(color, 0.16) : tk.surface3,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.onest(
                    fontSize: 17 * uiScale,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  child: Text(ten),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/10',
                style: TextStyle(
                  fontSize: 13 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: tk.onFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Спектр оценки (red→green) — всегда виден; позицию задаёт бегунок.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      gradient: LinearGradient(colors: tk.scoreRamp),
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: tk.surface2,
                    overlayColor: color.withValues(alpha: 0.16),
                    thumbShape: _RingThumb(color: color),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: (value ?? 0).toDouble(),
                    max: 100,
                    onChanged: _onSlide,
                  ),
                ),
              ],
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

/// Бегунок-кольцо: surface-заливка + 2 px обводка цветом текущей градации.
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

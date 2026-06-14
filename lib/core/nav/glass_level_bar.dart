import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Полоска «степень эффекта стекла»: дорожка + анимированные заливка/ползунок
/// (`AnimatedPositioned`) + точки-ступени. Тап/перетаскивание → ближайшая
/// ступень (Min слева — плотно, Max справа — прозрачно).
class GlassLevelBar extends StatelessWidget {
  const GlassLevelBar({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        const thumb = 22.0;
        const r = thumb / 2;
        final travel = (w - thumb).clamp(0.0, double.infinity);
        final frac = max <= 0 ? 0.0 : value / max;
        final cx = r + travel * frac;

        void pick(double dx) {
          if (travel <= 0) return;
          final f = ((dx - r) / travel).clamp(0.0, 1.0);
          final lvl = (f * max).round();
          if (lvl != value) onChanged(lvl);
        }

        const trackTop = 15.0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => pick(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => pick(d.localPosition.dx),
          child: SizedBox(
            height: 36,
            width: double.infinity,
            child: Stack(
              children: [
                // Неактивная дорожка.
                Positioned(
                  left: r,
                  right: r,
                  top: trackTop,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tk.onBg.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Активная заливка.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  left: r,
                  top: trackTop,
                  height: 6,
                  width: (cx - r).clamp(0.0, travel),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tk.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Точки-ступени.
                for (int i = 0; i <= max; i++)
                  Positioned(
                    left: r + travel * (max <= 0 ? 0.0 : i / max) - 3,
                    top: trackTop,
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: i <= value
                            ? tk.onPrimary.withValues(alpha: 0.9)
                            : tk.onBg.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                // Ползунок.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  left: cx - r,
                  top: trackTop + 3 - r,
                  width: thumb,
                  height: thumb,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tk.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: tk.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: tk.primary.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Подпись у края полоски степени стекла (Max/Min).
class GlassEndLabel extends StatelessWidget {
  const GlassEndLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: context.tokens.onBg.withValues(alpha: 0.4),
      ),
    );
  }
}

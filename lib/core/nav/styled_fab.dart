import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/theme_context.dart';
import 'breathing_gradient.dart';
import 'fab_style.dart';

/// alpha заливки и sigma размытия по ступени стекла FAB (зеркалит навигацию).
({double alpha, double sigma}) fabGlassParams(int level) {
  final t = level.clamp(0, FabStyleCubit.maxGlassLevel) /
      FabStyleCubit.maxGlassLevel;
  return (
    alpha: 0.78 + (0.05 - 0.78) * t,
    sigma: 3.0 + (32.0 - 3.0) * t,
  );
}

/// Кнопка добавления в выбранном стиле: круглая (`plain`) или пилюля (`labeled`);
/// заливка — матовое стекло / анимированный «дышащий» градиент / сплошной акцент.
/// Состояние из [FabStyleCubit] (или [stateOverride] для превью пикера).
class StyledFab extends StatelessWidget {
  const StyledFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.stateOverride,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final FabStyleState? stateOverride;

  static const double _h = 56;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final s = stateOverride ?? context.watch<FabStyleCubit>().state;
    final labeled = s.style == FabStyle.labeled;
    final ShapeBorder shape =
        labeled ? const StadiumBorder() : const CircleBorder();

    // Заливка + цвет контента + опц. контур (для стекла).
    final Color fg;
    final Widget fill;
    BorderSide? side;
    if (s.glass) {
      final p = fabGlassParams(s.glassLevel);
      fg = tk.primary; // на матовом стекле читается акцентом, не onPrimary
      side = BorderSide(color: tk.primary.withValues(alpha: 0.45), width: 1.2);
      fill = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: p.sigma, sigmaY: p.sigma),
        child: ColoredBox(color: tk.surface.withValues(alpha: p.alpha)),
      );
    } else if (s.gradient) {
      fg = tk.onPrimary;
      fill = BreathingGradient(colors: breathingColors(tk.primary, tk.secondary));
    } else {
      fg = tk.onPrimary;
      fill = ColoredBox(color: tk.primary);
    }

    final Widget content = labeled
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: fg, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ],
            ),
          )
        : Center(child: Icon(icon, color: fg, size: 24));

    return Container(
      // Тень — на форме без контура, чтобы кнопка «парила».
      decoration: ShapeDecoration(
        shape: shape,
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Stack(
          children: [
            Positioned.fill(child: fill),
            // Контент задаёт размер Stack (круг 56×56 / пилюля по тексту).
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox(
                  height: _h,
                  width: labeled ? null : _h,
                  child: content,
                ),
              ),
            ),
            if (side != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: labeled
                          ? StadiumBorder(side: side)
                          : CircleBorder(side: side),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

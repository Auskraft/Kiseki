import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import 'nav_style.dart';

/// alpha фона и sigma размытия по ступени стекла (0 — плотнее, max — прозрачнее).
({double alpha, double sigma}) navGlassParams(int level) {
  final t = level.clamp(0, NavStyleCubit.maxGlassLevel) /
      NavStyleCubit.maxGlassLevel;
  return (
    alpha: 0.78 + (0.05 - 0.78) * t, // 0.78 (плотно) → 0.05 (почти прозрачно)
    sigma: 3.0 + (32.0 - 3.0) * t, // 3 (Min: лёгкое) → 32 (Max: макс. размытие)
  );
}

/// Подложка нав-бара: при [glass] — «стекло» (BackdropFilter blur +
/// полупрозрачный фон по ступени [glassLevel]), иначе сплошная поверхность.
/// Тонкий контур одинаков в обоих режимах. Тень и внешний радиус — на стороне
/// бара. Цвета — только из токенов (ADR-17).
class NavBarSurface extends StatelessWidget {
  const NavBarSurface({
    super.key,
    required this.glass,
    required this.glassLevel,
    required this.radius,
    required this.child,
  });

  final bool glass;
  final int glassLevel;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final br = BorderRadius.circular(radius);
    final border = Border.all(color: tk.onBg.withValues(alpha: 0.06), width: 1);

    if (!glass) {
      return DecoratedBox(
        decoration: BoxDecoration(
            color: tk.surface, border: border, borderRadius: br),
        child: child,
      );
    }

    final p = navGlassParams(glassLevel);
    // RepaintBoundary изолирует дорогой BackdropFilter в отдельный слой:
    // перерисовка содержимого бара (морф капсулы, градиент) не тащит за собой
    // пересчёт blur, и наоборот.
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: p.sigma, sigmaY: p.sigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tk.surface.withValues(alpha: p.alpha),
              border: border,
              borderRadius: br,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

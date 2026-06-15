import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_context.dart';
import 'breathing_gradient.dart';
import 'nav_bar_surface.dart';
import 'nav_style.dart';

/// Нав-бар «Капсула» (стиль [NavBarStyle.capsule]).
///
/// Активная вкладка раскрыта в капсулу с иконкой + подписью; остальные —
/// иконки-кружки. При переключении капсула морфит (анимация ширины). Активная
/// капсула залита анимированным градиентом акцентов темы (при [gradient]) либо
/// плоским цветом. Подложка — «стекло» или сплошная.
class CapsuleNavBar extends StatefulWidget {
  const CapsuleNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.glass = true,
    this.glassLevel = 2,
    this.gradient = true,
  });

  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool glass;
  final int glassLevel;
  final bool gradient;

  @override
  State<CapsuleNavBar> createState() => _CapsuleNavBarState();
}

class _CapsuleNavBarState extends State<CapsuleNavBar>
    with TickerProviderStateMixin {
  // Морф капсулы между вкладками.
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..value = 1.0;
  late final Animation<double> _move =
      CurvedAnimation(parent: _ctrl, curve: Curves.fastOutSlowIn);

  late int _fromIndex = widget.currentIndex;

  @override
  void didUpdateWidget(CapsuleNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _fromIndex = old.currentIndex;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const double _itemH = 44;
  static const double _gap = 8;
  static const double _iconSize = 22;
  static const double _barRadius = 100;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final systemBottom = MediaQuery.of(context).padding.bottom;

    // Дышащий градиент из акцентов темы (общий с FAB).
    final gradColors = breathingColors(tk.primary, tk.secondary);

    final gradientOn = widget.gradient;
    final activeFg = tk.onPrimary;
    final inactiveIcon = tk.onBg.withValues(alpha: 0.5);
    final inactiveCircle = tk.onBg.withValues(alpha: 0.06);

    final items = widget.items;
    final count = items.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(40, 6, 40, systemBottom + 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_barRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: NavBarSurface(
          glass: widget.glass,
          glassLevel: widget.glassLevel,
          radius: _barRadius,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final extra = (w - count * _itemH - _gap * (count - 1) - 1)
                    .clamp(0.0, 1e6);

                // Перестраиваем Row только под морф капсулы (_move); вечный глоу
                // ведёт сам _CapsuleItem в изолированном RepaintBoundary — иначе
                // 60-fps градиент пересчитывал бы blur стекла всего бара.
                return AnimatedBuilder(
                  animation: _move,
                  builder: (context, _) {
                    final t = _move.value;

                    double activeness(int i) {
                      var a = 0.0;
                      if (i == _fromIndex) a += 1 - t;
                      if (i == widget.currentIndex) a += t;
                      return a.clamp(0.0, 1.0);
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < count; i++) ...[
                          if (i > 0) const SizedBox(width: _gap),
                          _CapsuleItem(
                            width: _itemH + activeness(i) * extra,
                            height: _itemH,
                            circleW: _itemH,
                            openness: activeness(i),
                            icon: items[i].icon,
                            label: items[i].label,
                            iconSize: _iconSize,
                            gradientColors: gradColors,
                            useGradient: gradientOn,
                            activeSolid: tk.primary,
                            activeFg: activeFg,
                            inactiveIcon: inactiveIcon,
                            inactiveCircle: inactiveCircle,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onTap(i);
                            },
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Один элемент бара «Капсула»: кружок (openness 0) ↔ капсула с подписью (1).
/// При раскрытии серый фон кружка сменяется анимированным градиентом акцентов.
class _CapsuleItem extends StatelessWidget {
  const _CapsuleItem({
    required this.width,
    required this.height,
    required this.circleW,
    required this.openness,
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.gradientColors,
    required this.useGradient,
    required this.activeSolid,
    required this.activeFg,
    required this.inactiveIcon,
    required this.inactiveCircle,
    required this.onTap,
  });

  final double width;
  final double height;
  final double circleW;
  final double openness; // 0..1
  final IconData icon;
  final String label;
  final double iconSize;
  final List<Color> gradientColors;
  final bool useGradient;
  final Color activeSolid;
  final Color activeFg;
  final Color inactiveIcon;
  final Color inactiveCircle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Color.lerp(inactiveIcon, activeFg, openness)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: inactiveCircle,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          children: [
            // Градиент-«дыхание» проявляется по мере раскрытия. Вечная
            // перерисовка изолирована в RepaintBoundary (blur стекла не
            // пересчитывается от глоу).
            if (openness > 0.001)
              Positioned.fill(
                child: Opacity(
                  opacity: openness,
                  child: useGradient
                      ? BreathingGradient(colors: gradientColors)
                      : ColoredBox(color: activeSolid),
                ),
              ),
            // Контент: иконка в зоне кружка + подпись справа.
            Row(
              children: [
                SizedBox(
                  width: circleW,
                  child: Center(
                    child: Icon(icon, size: iconSize, color: fg),
                  ),
                ),
                Expanded(
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Opacity(
                        opacity: openness,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Градиент капсулы вынесен в общий BreathingGradient (core/nav/breathing_gradient).

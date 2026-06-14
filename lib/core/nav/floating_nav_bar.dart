import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_context.dart';
import 'nav_bar_surface.dart';
import 'nav_style.dart';

/// Плавающий «жидкий» нав-бар (стиль [NavBarStyle.floating]).
///
/// Светящийся шар (цвет акцента темы) над активной вкладкой; при переезде тянет
/// за собой каплю-перемычку (metaball) и мягко её втягивает. Подложка — «стекло»
/// или сплошная. Подписи у всех вкладок (активная 100%, неактивные 30%).
class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.glass = true,
    this.glassLevel = 2,
  });

  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool glass;
  final int glassLevel;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..value = 1.0;
  late final Animation<double> _move =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubicEmphasized);

  late int _fromIndex = widget.currentIndex;

  @override
  void didUpdateWidget(FloatingNavBar old) {
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

  static const double _orbAreaH = 42;
  static const double _labelH = 16;
  static const double _iconSize = 28;
  static const double _orbR = 20;
  static const double _barRadius = 100;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final systemBottom = MediaQuery.of(context).padding.bottom;

    final orbColor = tk.primary;
    final orbFg = tk.onPrimary;
    final inactiveColor = tk.onBg.withValues(alpha: 0.3);

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
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final slotW = w / count;
                const centerY = _orbAreaH / 2;

                return AnimatedBuilder(
                  animation: _move,
                  builder: (context, _) {
                    final t = _move.value;
                    final orbPos =
                        _fromIndex + (widget.currentIndex - _fromIndex) * t;
                    final orbX = (orbPos + 0.5) * slotW;
                    final srcX = (_fromIndex + 0.5) * slotW;
                    final raw = orbX - srcX;
                    final tailX = raw == 0
                        ? srcX
                        : orbX - raw.sign * raw.abs().clamp(0.0, slotW * 1.15);

                    return Stack(
                      children: [
                        // ── Визуальный слой ──
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: _orbAreaH,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _LiquidNavPainter(
                                        centerY: centerY,
                                        orbX: orbX,
                                        srcX: tailX,
                                        progress: t,
                                        orbR: _orbR,
                                        orbColor: orbColor,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(count, (i) {
                                      final near = (1 - (orbPos - i).abs())
                                          .clamp(0.0, 1.0);
                                      final color = Color.lerp(
                                          inactiveColor, orbFg, near)!;
                                      return Expanded(
                                        child: Center(
                                          child: Icon(
                                            items[i].icon,
                                            size: _iconSize,
                                            color: color,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            // ── Подписи у всех; неактивные — 30% ──
                            SizedBox(
                              height: _labelH,
                              child: Row(
                                children: List.generate(count, (i) {
                                  final near = (1 - (orbPos - i).abs())
                                      .clamp(0.0, 1.0);
                                  return Expanded(
                                    child: Opacity(
                                      opacity: 0.3 + 0.7 * near,
                                      child: Text(
                                        items[i].label,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.1,
                                          fontWeight: FontWeight.w700,
                                          color: tk.onBg,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        // ── Слой тапов (вся высота слота) ──
                        Positioned.fill(
                          child: Row(
                            children: List.generate(count, (i) {
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    widget.onTap(i);
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
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

/// Жидкий индикатор: светящийся шар над активной вкладкой; при переезде тянет
/// сужающуюся каплю-перемычку от исходного слота (metaball — перекрывающиеся
/// заливки одного цвета сливаются без швов).
class _LiquidNavPainter extends CustomPainter {
  _LiquidNavPainter({
    required this.centerY,
    required this.orbX,
    required this.srcX,
    required this.progress,
    required this.orbR,
    required this.orbColor,
  });

  final double centerY;
  final double orbX;
  final double srcX;
  final double progress;
  final double orbR;
  final Color orbColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Свечение шара (мягкий bloom).
    canvas.drawCircle(
      Offset(orbX, centerY),
      orbR,
      Paint()
        ..color = orbColor.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final fill = Paint()..color = orbColor;
    final rs = orbR * (1 - progress).clamp(0.0, 1.0);
    final p2 = progress * progress;
    final retract = p2 * p2; // progress^4 — хвост держится почти всю дорогу
    final anchorX = srcX + (orbX - srcX) * retract;
    final gap = (orbX - anchorX).abs();
    if (gap > 1.5) {
      canvas.drawCircle(Offset(anchorX, centerY), rs, fill);
      final neckHalf = (rs + orbR) / 2 * 0.52;
      final midX = (anchorX + orbX) / 2;
      final bridge = Path()
        ..moveTo(anchorX, centerY - rs)
        ..cubicTo(midX, centerY - neckHalf, midX, centerY - neckHalf, orbX,
            centerY - orbR)
        ..lineTo(orbX, centerY + orbR)
        ..cubicTo(midX, centerY + neckHalf, midX, centerY + neckHalf, anchorX,
            centerY + rs)
        ..close();
      canvas.drawPath(bridge, fill);
    }
    canvas.drawCircle(Offset(orbX, centerY), orbR, fill);
  }

  @override
  bool shouldRepaint(_LiquidNavPainter old) =>
      old.orbX != orbX ||
      old.srcX != srcX ||
      old.progress != progress ||
      old.orbColor != orbColor;
}

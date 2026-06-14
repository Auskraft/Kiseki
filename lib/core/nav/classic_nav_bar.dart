import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_context.dart';
import 'nav_bar_surface.dart';
import 'nav_style.dart';

/// Классический плавающий нав-бар (стиль [NavBarStyle.classic]).
///
/// Пилюля-подложка («стекло» или сплошная), скользящий индикатор активной
/// вкладки (бледный акцент), лёгкий «pop» иконки, подписи у всех вкладок.
class ClassicNavBar extends StatelessWidget {
  const ClassicNavBar({
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
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final systemBottom = MediaQuery.of(context).padding.bottom;
    final active = tk.primary;
    final inactive = tk.onBg.withValues(alpha: 0.4);
    final count = items.length;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(40, 6, 40, systemBottom + 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: NavBarSurface(
          glass: glass,
          glassLevel: glassLevel,
          radius: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Stack(
              children: [
                // ── Скользящий индикатор активной вкладки ──
                Positioned.fill(
                  child: AnimatedAlign(
                    alignment: Alignment(2 * currentIndex / (count - 1) - 1, 0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: FractionallySizedBox(
                      widthFactor: 1 / count,
                      heightFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: active.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Вкладки ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(count, (i) {
                    final item = items[i];
                    final selected = i == currentIndex;
                    final color = selected ? active : inactive;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(i);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: selected ? 1.12 : 1.0,
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutBack,
                                child: Icon(item.icon, size: 25, color: color),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

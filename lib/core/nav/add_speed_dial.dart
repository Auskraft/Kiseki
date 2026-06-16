import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'fab_style.dart';
import 'styled_fab.dart';

/// Одно действие speed-dial: иконка мини-кнопки, подпись слева, обработчик.
class SpeedDialAction {
  const SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Кнопка «Добавить», раскрывающаяся в мини-кнопки (как «написать» в Telegram).
/// По тапу показывает над собой [actions] с затемнением фона и закрытием по
/// тапу вне. Главная кнопка — [StyledFab] в выбранном пользователем стиле;
/// мини-действия и крестик привязаны к её позиции через [LayerLink], поэтому
/// работают при любом расположении/стиле FAB.
class AddSpeedDial extends StatefulWidget {
  const AddSpeedDial({super.key, required this.actions});

  final List<SpeedDialAction> actions;

  @override
  State<AddSpeedDial> createState() => _AddSpeedDialState();
}

class _AddSpeedDialState extends State<AddSpeedDial>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _ctrl;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    // Создаём контроллер сразу (не лениво): иначе при размонтировании без
    // раскрытия его init сработал бы в dispose → unsafe ancestor lookup.
    _ctrl = AnimationController(vsync: this, duration: AppDurations.base)
      ..addStatusListener((s) {
        // Прячем оверлей по завершении обратной анимации (мини-кнопки не
        // исчезают рывком).
        if (s == AnimationStatus.dismissed) _portal.hide();
      });
    _curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  void _expand() {
    HapticFeedback.selectionClick();
    _portal.show();
    _ctrl.forward();
  }

  void _collapse() {
    HapticFeedback.selectionClick();
    _ctrl.reverse();
  }

  void _toggle() => _portal.isShowing ? _collapse() : _expand();

  void _run(SpeedDialAction action) {
    _collapse();
    action.onTap();
  }

  @override
  void dispose() {
    _curve.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        // Видимая кнопка в слоте FAB; раскрытый крестик рисуется поверх неё.
        child: StyledFab(
          icon: Icons.add,
          label: 'Добавить',
          onPressed: _toggle,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    // Подпись у мини-кнопок — только при стиле FAB «С подписью»; для «Иконка»
    // показываем лишь иконку (как и сама главная кнопка).
    final labeled =
        context.read<FabStyleCubit>().state.style == FabStyle.labeled;
    return Stack(
      children: [
        // Затемнение фона + закрытие по тапу вне.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _collapse,
            child: FadeTransition(
              opacity: _curve,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
        ),
        // Колонка действий + крестик, прижатая к позиции FAB (bottom-right).
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.bottomRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final action in widget.actions)
                _MiniAction(
                  action: action,
                  animation: _curve,
                  showLabel: labeled,
                  onTap: () => _run(action),
                ),
              // Крестик ровно поверх главной кнопки (тот же стиль и размер).
              StyledFab(
                icon: Icons.close_rounded,
                label: 'Добавить',
                onPressed: _collapse,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Мини-действие: круглая кнопка, центрированная под главной (ширина [_slot] =
/// размер FAB), и — если включён стиль FAB «С подписью» ([showLabel]) — подпись-
/// пилюля слева. Появляется «выплыванием» из FAB (scale+fade, без растяжения).
class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.action,
    required this.animation,
    required this.showLabel,
    required this.onTap,
  });

  final SpeedDialAction action;
  final Animation<double> animation;
  final bool showLabel;
  final VoidCallback onTap;

  /// Ширина слота под мини-кнопкой = ширина круглого [StyledFab] (центрируем
  /// мини-кнопку ровно над главной).
  static const double _slot = 56;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    // Scale+Fade — proxy-размера, не меняют ширину. SizeTransition здесь нельзя:
    // он растягивается во всю ширину и лево-выравнивает контент → всё «съезжает».
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLabel) ...[
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      action.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13 * uiScale,
                        fontWeight: FontWeight.w700,
                        color: tk.onBg,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              SizedBox(
                width: _slot,
                child: Center(
                  child: Material(
                    color: tk.surface,
                    shape:
                        CircleBorder(side: BorderSide(color: tk.outlineSoft)),
                    elevation: 3,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    child: InkWell(
                      onTap: onTap,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Icon(action.icon, color: tk.primary, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

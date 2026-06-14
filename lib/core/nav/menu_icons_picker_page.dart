import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'capsule_nav_bar.dart';
import 'classic_nav_bar.dart';
import 'floating_nav_bar.dart';
import 'menu_icons.dart';
import 'nav_style.dart';

/// Настройки → Визуальный стиль → «Иконки меню». Для каждой из 4 вкладок можно
/// выбрать свою иконку из набора. Применяется сразу (бар обновляется). Сверху —
/// живое превью реального нав-бара выбранного стиля с этими иконками.
class MenuIconsPickerPage extends StatefulWidget {
  const MenuIconsPickerPage({super.key});

  @override
  State<MenuIconsPickerPage> createState() => _MenuIconsPickerPageState();
}

class _MenuIconsPickerPageState extends State<MenuIconsPickerPage> {
  int _editingTab = 0;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final icons = context.watch<MenuIconsCubit>().state;
    final cubit = context.read<MenuIconsCubit>();
    final systemBottom = MediaQuery.of(context).padding.bottom;
    final isDefault = icons == const MenuIconsState(kMenuIconDefaults);
    final editingLabel = kNavDestinations[_editingTab].label;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + systemBottom),
                children: [
                  // ── Живое превью реального бара с выбранными иконками ──
                  _NavPreview(
                    editingTab: _editingTab,
                    onTapTab: (i) => setState(() => _editingTab = i),
                  ),
                  const SizedBox(height: 18),

                  // ── Выбор вкладки ──
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Какую вкладку настроить',
                          style: TextStyle(fontSize: 13 * uiScale, color: tk.onMuted),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (var i = 0; i < kNavDestinations.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: _TabChip(
                                  label: kNavDestinations[i].label,
                                  icon: icons.iconFor(i),
                                  selected: i == _editingTab,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _editingTab = i);
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Сетка иконок для выбранной вкладки ──
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Иконка для «$editingLabel»',
                          style: TextStyle(
                            fontSize: 15.5 * uiScale,
                            fontWeight: FontWeight.w700,
                            color: tk.onBg,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 6,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: [
                            for (final e in kMenuIconPool)
                              _IconCell(
                                icon: e.icon,
                                selected: icons.keys[_editingTab] == e.key,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  cubit.setIcon(_editingTab, e.key);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Сброс ──
                  OutlinedButton.icon(
                    onPressed: isDefault
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            cubit.reset();
                          },
                    icon: const Icon(Icons.restart_alt_rounded, size: 20),
                    label: const Text('Сбросить к стандартным'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tk.onBg),
            tooltip: 'Назад',
            onPressed: () => context.pop(),
          ),
          Text('Иконки меню', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Живое превью = реальный нав-бар выбранного «Стиля навигации» с выбранными
/// иконками; редактируемая вкладка подсвечена как активная, тап выбирает её.
class _NavPreview extends StatelessWidget {
  const _NavPreview({required this.editingTab, required this.onTapTab});

  final int editingTab;
  final ValueChanged<int> onTapTab;

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavStyleCubit>().state;
    final icons = context.watch<MenuIconsCubit>().state;
    final items = navItemsFor(icons);

    final Widget bar = switch (nav.style) {
      NavBarStyle.classic => ClassicNavBar(
          items: items,
          currentIndex: editingTab,
          onTap: onTapTab,
          glass: nav.glass,
          glassLevel: nav.glassLevel,
        ),
      NavBarStyle.floating => FloatingNavBar(
          items: items,
          currentIndex: editingTab,
          onTap: onTapTab,
          glass: nav.glass,
          glassLevel: nav.glassLevel,
        ),
      NavBarStyle.capsule => CapsuleNavBar(
          items: items,
          currentIndex: editingTab,
          onTap: onTapTab,
          glass: nav.glass,
          glassLevel: nav.glassLevel,
          gradient: nav.gradient,
        ),
    };

    // Бары добавляют системный нижний отступ — в превью он дал бы пустоту снизу.
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: bar,
    );
  }
}

/// Карточка-контейнер в стиле визуальных пикеров.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: child,
    );
  }
}

/// Чип выбора вкладки: иконка + название; подсветка редактируемой.
class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final fg = selected ? tk.primary : tk.onBg.withValues(alpha: 0.7);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? tk.primary.withValues(alpha: 0.12)
              : tk.onBg.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? tk.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: fg),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11 * uiScale,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ячейка сетки иконок: квадрат с иконкой; выбранная — акцент-рамка + галочка.
class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected
                  ? tk.primary.withValues(alpha: 0.12)
                  : tk.onBg.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: selected ? tk.primary : tk.outlineSoft,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 26,
                color: selected ? tk.primary : tk.onBg.withValues(alpha: 0.8),
              ),
            ),
          ),
          if (selected)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: tk.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded,
                    size: 12, color: tk.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

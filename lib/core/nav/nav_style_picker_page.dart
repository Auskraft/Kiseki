import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'capsule_nav_bar.dart';
import 'classic_nav_bar.dart';
import 'floating_nav_bar.dart';
import 'glass_level_bar.dart';
import 'nav_style.dart';

/// Пикер стиля нижней навигации: сверху живой «телефон» с выбранным баром, под
/// ним — чипы выбора, тумблеры (градиент/стекло), степень стекла и описание.
/// Тап по чипу = выбор + применение сразу (single-select); превью обновляется
/// живьём. Возврат — кнопкой «назад».
class NavStylePickerPage extends StatelessWidget {
  const NavStylePickerPage({super.key});

  // Индекс-витрина: средняя вкладка показывает морф/слайд не у самого края.
  static const int _previewIndex = 1;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final s = context.watch<NavStyleCubit>().state;
    final cubit = context.read<NavStyleCubit>();
    final systemBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            // ── Живая витрина выбранного стиля ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _PhonePreview(
                      key: ValueKey(s.style),
                      state: s,
                      currentIndex: _previewIndex,
                    ),
                  ),
                ),
              ),
            ),
            // ── Чипы выбора ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final style in NavBarStyle.values)
                    _StyleChip(
                      label: style.title,
                      selected: style == s.style,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        cubit.setStyle(style);
                      },
                    ),
                ],
              ),
            ),
            // ── Тумблер «Градиент и анимация» (только «Капсула») ──
            if (s.style == NavBarStyle.capsule)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _ToggleRow(
                  icon: Icons.gradient_rounded,
                  label: 'Градиент и анимация цвета',
                  value: s.gradient,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    cubit.setGradient(v);
                  },
                ),
              ),
            // ── Тумблер «эффект стекла» (общий) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ToggleRow(
                icon: Icons.blur_on_rounded,
                label: 'Эффект стекла',
                value: s.glass,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  cubit.setGlass(v);
                },
              ),
            ),
            // ── Степень стекла (только при включённом стекле) ──
            if (s.glass)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Степень стекла',
                        style: TextStyle(
                          fontSize: 13 * uiScale,
                          fontWeight: FontWeight.w600,
                          color: tk.onMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassLevelBar(
                      value: s.glassLevel,
                      max: NavStyleCubit.maxGlassLevel,
                      onChanged: (lvl) {
                        HapticFeedback.selectionClick();
                        cubit.setGlassLevel(lvl);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [GlassEndLabel('Плотно'), GlassEndLabel('Прозрачно')],
                      ),
                    ),
                  ],
                ),
              ),
            // ── Описание выбранного ──
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  s.style.description,
                  key: ValueKey(s.style),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * uiScale,
                    height: 1.3,
                    color: tk.onMuted,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18 + systemBottom),
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
          Text('Стиль навигации',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Чип выбора стиля: пилюля; у выбранного — лёгкая заливка акцентом + галочка.
class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tk.primary.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: selected ? tk.primary : tk.outline,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_circle_rounded, size: 18, color: tk.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14 * uiScale,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? tk.primary : tk.onMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка-тумблер (иконка + подпись + Switch) в карточке-пилюле.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: tk.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: tk.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.5 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onBg,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Мини-«телефон» с условным контентом и НАСТОЯЩИМ нав-баром снизу. Бар
/// рендерится на виртуальной ширине телефона (верные пропорции) и масштабируется
/// `FittedBox`. MediaQuery padding обнулён; бар неинтерактивен.
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({
    super.key,
    required this.state,
    required this.currentIndex,
  });

  final NavStyleState state;
  final int currentIndex;

  static const double _vw = 380;
  static const double _vh = 760;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    void noop(int _) {}

    Widget bar;
    switch (state.style) {
      case NavBarStyle.classic:
        bar = ClassicNavBar(
          items: kNavDestinations,
          currentIndex: currentIndex,
          onTap: noop,
          glass: state.glass,
          glassLevel: state.glassLevel,
        );
      case NavBarStyle.floating:
        bar = FloatingNavBar(
          items: kNavDestinations,
          currentIndex: currentIndex,
          onTap: noop,
          glass: state.glass,
          glassLevel: state.glassLevel,
        );
      case NavBarStyle.capsule:
        bar = CapsuleNavBar(
          items: kNavDestinations,
          currentIndex: currentIndex,
          onTap: noop,
          glass: state.glass,
          glassLevel: state.glassLevel,
          gradient: state.gradient,
        );
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: _vw,
        height: _vh,
        decoration: BoxDecoration(
          color: tk.surface,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: tk.outline),
        ),
        clipBehavior: Clip.antiAlias,
        // Бар поверх контента (как extendBody) — иначе за баром пусто и эффект
        // стекла не виден.
        child: Stack(
          children: [
            const Positioned.fill(child: _FauxScreen()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                  viewInsets: EdgeInsets.zero,
                ),
                child: IgnorePointer(child: bar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Условный контент экрана (шапка-градиент + карточки-плейсхолдеры).
class _FauxScreen extends StatelessWidget {
  const _FauxScreen();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final ph = tk.onBg.withValues(alpha: 0.08);
    Widget card() => DecoratedBox(
          decoration: BoxDecoration(
            color: ph,
            borderRadius: BorderRadius.circular(16),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tk.primary.withValues(alpha: 0.85),
                  tk.primary.withValues(alpha: 0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 150,
            height: 14,
            decoration: BoxDecoration(
              color: ph,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Expanded(child: card()),
                const SizedBox(height: 14),
                Expanded(child: card()),
                const SizedBox(height: 14),
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [tk.primary, tk.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'fab_style.dart';
import 'glass_level_bar.dart';
import 'styled_fab.dart';

/// Пикер стиля кнопки добавления (FAB): живой «телефон» с настоящей кнопкой в
/// выбранном виде + чипы + тумблеры стекло/градиент + степень стекла. Применяется
/// сразу.
class FabStylePickerPage extends StatelessWidget {
  const FabStylePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final s = context.watch<FabStyleCubit>().state;
    final cubit = context.read<FabStyleCubit>();
    final systemBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Center(child: _PhonePreview(state: s)),
              ),
            ),
            // ── Чипы выбора вида ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final style in FabStyle.values)
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
            // ── Тумблер «Анимированный градиент» (когда стекло выключено) ──
            if (!s.glass)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _ToggleRow(
                  icon: Icons.gradient_rounded,
                  label: 'Анимированный градиент',
                  value: s.gradient,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    cubit.setGradient(v);
                  },
                ),
              ),
            // ── Тумблер «эффект стекла» ──
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
            // ── Степень стекла ──
            if (s.glass)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text('Степень стекла',
                          style: TextStyle(
                              fontSize: 13 * uiScale,
                              fontWeight: FontWeight.w600,
                              color: tk.onMuted)),
                    ),
                    const SizedBox(height: 8),
                    GlassLevelBar(
                      value: s.glassLevel,
                      max: FabStyleCubit.maxGlassLevel,
                      onChanged: (lvl) {
                        HapticFeedback.selectionClick();
                        cubit.setGlassLevel(lvl);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GlassEndLabel('Плотно'),
                          GlassEndLabel('Прозрачно')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // ── Описание ──
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
              child: Text(
                s.style.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14 * uiScale, height: 1.3, color: tk.onMuted),
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
          Text('Кнопка добавления',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip(
      {required this.label, required this.selected, required this.onTap});

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
          color:
              selected ? tk.primary.withValues(alpha: 0.12) : Colors.transparent,
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
            child: Text(label,
                style: TextStyle(
                    fontSize: 14.5 * uiScale,
                    fontWeight: FontWeight.w600,
                    color: tk.onBg)),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Мини-«телефон» с условным контентом и настоящим [StyledFab] в правом нижнем
/// углу. Масштабируется `FittedBox`; кнопка неинтерактивна.
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.state});

  final FabStyleState state;

  static const double _vw = 360;
  static const double _vh = 720;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
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
        child: Stack(
          children: [
            const Positioned.fill(child: _FauxScreen()),
            Positioned(
              right: 20,
              bottom: 24,
              child: IgnorePointer(
                child: StyledFab(
                  stateOverride: state,
                  icon: Icons.add,
                  label: 'Добавить',
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 116,
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
                color: ph, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
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
                      borderRadius: BorderRadius.circular(16),
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

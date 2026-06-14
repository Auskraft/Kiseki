import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app_dimens.dart';
import 'kiseki_theme_id.dart';
import 'kiseki_themes.dart';
import 'kiseki_tokens.dart';
import 'theme_context.dart';
import 'theme_cubit.dart';

/// Настройки → Визуальный стиль → «Тема оформления». Переключатель режима +
/// сетка карточек-превью всех тем (каждая в текущем режиме). Тап = смена сразу.
/// Структура — из пикера тем «дневника давления», адаптирована под токены.
class ThemePickerPage extends StatelessWidget {
  const ThemePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ThemeCubit>().state;
    final cubit = context.read<ThemeCubit>();
    final brightness = Theme.of(context).brightness;
    final systemBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_rounded, size: 17),
                    label: Text('Светлая'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_rounded, size: 17),
                    label: Text('Тёмная'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_rounded, size: 17),
                    label: Text('Авто'),
                  ),
                ],
                selected: {state.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (s) => cubit.setMode(s.first),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + systemBottom),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: KisekiThemeId.values.length,
                itemBuilder: (context, i) {
                  final id = KisekiThemeId.values[i];
                  return _ThemeCard(
                    id: id,
                    brightness: brightness,
                    selected: id == state.themeId,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      cubit.setTheme(id);
                    },
                  );
                },
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
          Text('Тема оформления',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Карточка темы: мини-превью экрана в цветах темы + название + галочка.
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.id,
    required this.brightness,
    required this.selected,
    required this.onTap,
  });

  final KisekiThemeId id;
  final Brightness brightness;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokensFor(id, brightness); // цвета самой темы (для превью)
    final accent = context.tokens.primary; // акцент текущей темы (рамка/чек)
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: selected ? accent : t.outlineSoft,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _MiniPreview(t: t)),
            Container(
              color: t.surface,
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      id.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5 * uiScale,
                        fontWeight: FontWeight.w600,
                        color: t.onBg,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, size: 16, color: accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Мини-превью «экрана» в цветах темы: шапка-градиент + строка-заголовок +
/// ряд постеров-плейсхолдеров + чип.
class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.t});

  final KisekiTokens t;

  @override
  Widget build(BuildContext context) {
    Widget poster() => Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.surface3,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

    return Container(
      color: t.bg,
      padding: const EdgeInsets.all(9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [t.primary, t.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: t.onBg.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                poster(),
                const SizedBox(width: 6),
                poster(),
                const SizedBox(width: 6),
                poster(),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Container(
                width: 26,
                height: 9,
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 16,
                height: 9,
                decoration: BoxDecoration(
                  color: t.surface3,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

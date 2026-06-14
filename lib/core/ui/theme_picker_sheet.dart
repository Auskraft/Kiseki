import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_dimens.dart';
import '../theme/kiseki_theme_id.dart';
import '../theme/kiseki_themes.dart';
import '../theme/theme_context.dart';
import '../theme/theme_cubit.dart';

/// Боттомшит выбора темы (5 свотчей) и режима (светлая/тёмная/авто).
Future<void> showThemePicker(BuildContext context) {
  final cubit = context.read<ThemeCubit>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _ThemePickerSheet(),
    ),
  );
}

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    final state = context.watch<ThemeCubit>().state;
    final cubit = context.read<ThemeCubit>();

    return Container(
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tk.surface3,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Оформление', style: text.titleMedium),
          const SizedBox(height: 16),
          Text('Тема', style: text.labelMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              for (final id in KisekiThemeId.values)
                _Swatch(
                  id: id,
                  selected: state.themeId == id,
                  onTap: () => cubit.setTheme(id),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Режим', style: text.labelMedium),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Светлая')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная')),
              ButtonSegment(value: ThemeMode.system, label: Text('Авто')),
            ],
            selected: {state.themeMode},
            showSelectedIcon: false,
            onSelectionChanged: (s) => cubit.setMode(s.first),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.id, required this.selected, required this.onTap});

  final KisekiThemeId id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(selected ? 3 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected ? Border.all(color: tk.onBg, width: 2) : null,
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeSwatch(id),
                boxShadow: [
                  BoxShadow(
                    color: themeSwatch(id).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(id.label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

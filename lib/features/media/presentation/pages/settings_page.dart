import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/kiseki_theme_id.dart';
import '../../../../core/theme/kiseki_themes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/theme_cubit.dart';
import 'media_trash_page.dart';
import 'tags_page.dart';

/// Экран 06 — настройки: оформление, доступ к тегам/корзине, бэкап (стаб),
/// язык, о приложении. Хаб приложения (заменяет боттомшит выбора темы).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SettingsPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: const [
                  _SectionTitle('Резервная копия'),
                  _BackupCard(),
                  SizedBox(height: 20),
                  _SectionTitle('Внешний вид'),
                  _AppearanceCard(),
                  SizedBox(height: 20),
                  _SectionTitle('Каталог'),
                  _CatalogCard(),
                  SizedBox(height: 20),
                  _SectionTitle('Прочее'),
                  _MiscCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tk.onBg),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text('Настройки', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5 * uiScale,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: tk.onMuted,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: child,
    );
  }
}

// ─────────────────────────── бэкап (стаб) ────────────────────────────────

class _BackupCard extends StatelessWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tk.tint(tk.primary, 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(Icons.cloud_outlined, color: tk.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Яндекс.Диск',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text('не подключён',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: tk.tint(tk.warning, 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.construction_rounded, size: 15, color: tk.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Резервное копирование на Яндекс.Диск — в разработке.',
                    style: TextStyle(fontSize: 12 * uiScale, color: tk.onMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text('Сделать бэкап'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── внешний вид ─────────────────────────────────

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ThemeCubit>().state;
    final cubit = context.read<ThemeCubit>();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Тема', style: Theme.of(context).textTheme.labelMedium),
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
          const SizedBox(height: 18),
          Text('Режим', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeSwatch(id),
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

// ─────────────────────────── каталог (теги/корзина) ──────────────────────

class _CatalogCard extends StatelessWidget {
  const _CatalogCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _Row(
            icon: Icons.label_outline_rounded,
            title: 'Теги',
            onTap: () => Navigator.of(context).push(TagsPage.route()),
          ),
          const _Divider(),
          _Row(
            icon: Icons.delete_outline_rounded,
            title: 'Корзина',
            onTap: () => Navigator.of(context).push(MediaTrashPage.route()),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── прочее ──────────────────────────────────────

class _MiscCard extends StatelessWidget {
  const _MiscCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      child: Column(
        children: [
          _Row(icon: Icons.translate_rounded, title: 'Язык', trailing: 'Русский'),
          _Divider(),
          _Row(
            icon: Icons.info_outline_rounded,
            title: 'О приложении',
            trailing: 'Kiseki · 1.0.0',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
        child: Row(
          children: [
            Icon(icon, size: 20, color: tk.onMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (trailing != null)
              Text(trailing!, style: Theme.of(context).textTheme.bodySmall),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 20, color: tk.onFaint),
            ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: context.tokens.outlineSoft);
  }
}

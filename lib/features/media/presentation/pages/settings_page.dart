import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/restore_flow.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/backup/backup_archive.dart';
import '../../../../core/backup/backup_cubit.dart';
import '../../../../core/backup/yandex_disk_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/ui/confirm_sheet.dart';
import '../../../../core/nav/nav_style.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/theme_cubit.dart';

/// Экран 06 — настройки: оформление, доступ к тегам/корзине, бэкап (стаб),
/// язык, о приложении. Хаб приложения (заменяет боттомшит выбора темы).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.embedded = false});

  /// В оболочке как вкладка-корень (embedded=true) — без кнопки «назад».
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(embedded: embedded),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: const [
                  _SectionTitle('Резервное копирование'),
                  _BackupSection(),
                  SizedBox(height: 20),
                  _SectionTitle('Визуальный стиль'),
                  _VisualStyleCard(),
                  SizedBox(height: 20),
                  _SectionTitle('Прочее'),
                  _MiscCard(),
                  SizedBox(height: 20),
                  _SectionTitle('Документация'),
                  _DocsCard(),
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
  const _TopBar({this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
      child: Row(
        children: [
          if (!embedded)
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: tk.onBg),
              tooltip: 'Назад',
              onPressed: () => context.pop(),
            )
          else
            const SizedBox(width: 8),
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
        text,
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

String _fmtDateTime(DateTime d) {
  final l = d.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(l.day)}.${two(l.month)}.${l.year} ${two(l.hour)}:${two(l.minute)}';
}

class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BackupCubit(getIt<YandexDiskService>(), getIt<BackupArchive>()),
      child: const _BackupCard(),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard();

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Replace-all восстановление: подтверждение → прогресс → [runRestore]
  /// (при успехе перезапускает дерево, этот экран демонтируется).
  Future<void> _restore(BuildContext context) async {
    final ok = await showConfirmDeleteSheet(
      context,
      title: 'Восстановить из бэкапа?',
      message: 'Текущие карточки и картинки будут заменены копией с Я.Диска. '
          'Это действие необратимо.',
      confirmLabel: 'Восстановить',
    );
    if (!ok || !context.mounted) return;

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ));
    try {
      await runRestore(context);
      // Успех → дерево перезапущено, дальше выполнять нечего.
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // закрыть прогресс
      final msg = switch (e) {
        BackupException b => b.message,
        Failure f => f.message,
        _ => 'Не удалось восстановить',
      };
      _snack(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    return BlocConsumer<BackupCubit, BackupState>(
      listenWhen: (a, b) =>
          a.justBackedUp != b.justBackedUp || a.error != b.error,
      listener: (context, state) {
        if (state.justBackedUp) {
          _snack(context, 'Бэкап загружен на Я.Диск');
        } else if (state.error != null) {
          _snack(context, state.error!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<BackupCubit>();
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
                    child:
                        Icon(Icons.cloud_outlined, color: tk.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Яндекс.Диск', style: text.bodyLarge),
                        const SizedBox(height: 2),
                        if (state.linked)
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 13, color: tk.success),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  state.account == null
                                      ? 'Подключён'
                                      : 'Подключён · ${state.account}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall
                                      ?.copyWith(color: tk.success),
                                ),
                              ),
                            ],
                          )
                        else
                          Text('не подключён', style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (!state.linked)
                _BackupButton(
                  label: 'Подключить Я.Диск',
                  icon: Icons.link_rounded,
                  busy: state.busy,
                  onTap: cubit.connect,
                )
              else ...[
                Text(
                  state.lastBackup == null
                      ? 'Бэкапов ещё не было'
                      : 'Последний бэкап: ${_fmtDateTime(state.lastBackup!)}',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 10),
                _BackupButton(
                  label: 'Сделать бэкап',
                  icon: Icons.cloud_upload_outlined,
                  busy: state.busy,
                  onTap: cubit.backupNow,
                ),
                const SizedBox(height: 9),
                _RestoreButton(
                  busy: state.busy,
                  onTap: () => _restore(context),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: state.busy ? null : cubit.disconnect,
                    child:
                        Text('Отвязать', style: TextStyle(color: tk.onMuted)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BackupButton extends StatelessWidget {
  const _BackupButton({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton.icon(
        onPressed: busy ? null : onTap,
        icon: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 18),
        label: Text(busy ? 'Подождите…' : label),
      ),
    );
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final warn = Color.alphaBlend(tk.warning.withValues(alpha: 0.85), tk.onBg);
    return Material(
      color: tk.tint(tk.warning, 0.12),
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.settings_backup_restore_rounded,
                  size: 19, color: tk.warning),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Восстановить из бэкапа',
                        style: TextStyle(
                            fontSize: 13.5 * uiScale,
                            fontWeight: FontWeight.w600,
                            color: warn)),
                    Text('Заменит локальные данные',
                        style: TextStyle(
                            fontSize: 11.5 * uiScale, color: tk.onMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка «Визуальный стиль»: тема оформления, стиль навигации, иконки меню.
class _VisualStyleCard extends StatelessWidget {
  const _VisualStyleCard();

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.themeId;
    final navStyle = context.watch<NavStyleCubit>().state.style;
    return _Card(
      child: Column(
        children: [
          _Row(
            icon: Icons.palette_outlined,
            title: 'Тема оформления',
            trailing: themeId.label,
            onTap: () => context.push(AppRoute.theme),
          ),
          const _Divider(),
          _Row(
            icon: Icons.dashboard_rounded,
            title: 'Стиль навигации',
            trailing: navStyle.title,
            onTap: () => context.push(AppRoute.navStyle),
          ),
          const _Divider(),
          _Row(
            icon: Icons.apps_rounded,
            title: 'Иконки меню',
            onTap: () => context.push(AppRoute.menuIcons),
          ),
          const _Divider(),
          _Row(
            icon: Icons.add_circle_outline_rounded,
            title: 'Кнопка добавления',
            onTap: () => context.push(AppRoute.fabStyle),
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

class _DocsCard extends StatelessWidget {
  const _DocsCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: _Row(
        icon: Icons.privacy_tip_outlined,
        title: 'Политика конфиденциальности',
        onTap: () => context.push(AppRoute.privacy),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/confirm_sheet.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_repository.dart';
import '../cubit/media_trash_cubit.dart';
import '../widgets/cover_image.dart';

/// Сколько дней карточка хранится в корзине (информационно; авто-очистка по
/// сроку — nice-to-have, пока удаление ручное).
const int kTrashRetentionDays = 30;

/// Подпись срока: «удалено N дн. назад · через M дн.» (TECH_DESIGN §6.7 / 04).
String retentionLabel(DateTime deletedAt, DateTime now,
    {int retentionDays = kTrashRetentionDays}) {
  final passed = now.difference(deletedAt).inDays;
  final left = (retentionDays - passed).clamp(0, retentionDays);
  final deleted = passed <= 0 ? 'удалено сегодня' : 'удалено $passed дн. назад';
  return '$deleted · через $left дн.';
}

/// Экран 04 — корзина (мягко удалённые карточки): восстановление и
/// окончательное удаление.
class MediaTrashPage extends StatelessWidget {
  const MediaTrashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MediaTrashCubit(getIt<MediaRepository>()),
      child: const _TrashView(),
    );
  }
}

class _TrashView extends StatelessWidget {
  const _TrashView();

  Future<void> _clearAll(BuildContext context) async {
    final cubit = context.read<MediaTrashCubit>();
    final ok = await showConfirmDeleteSheet(
      context,
      title: 'Очистить корзину?',
      message: 'Все карточки в корзине будут удалены навсегда. '
          'Это действие необратимо.',
      confirmLabel: 'Очистить',
    );
    if (ok) await cubit.purgeAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MediaTrashCubit, MediaTrashState>(
          builder: (context, state) {
            return Column(
              children: [
                _TopBar(
                  showClear: state.items.isNotEmpty,
                  onClear: () => _clearAll(context),
                ),
                Expanded(
                  child: state.loading
                      ? const SizedBox.shrink()
                      : state.isEmpty
                          ? const _EmptyTrash()
                          : _TrashList(items: state.items),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showClear, required this.onClear});

  final bool showClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tk.onBg),
            tooltip: 'Назад',
            onPressed: () => context.pop(),
          ),
          Text('Корзина', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (showClear)
            TextButton(
              onPressed: onClear,
              child: Text('Очистить', style: TextStyle(color: tk.error)),
            ),
        ],
      ),
    );
  }
}

class _TrashList extends StatelessWidget {
  const _TrashList({required this.items});

  final List<MediaEntry> items;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemBuilder: (context, i) {
        if (i == 0) return const _RetentionBanner();
        return _TrashRow(entry: items[i - 1], now: now);
      },
    );
  }
}

class _RetentionBanner extends StatelessWidget {
  const _RetentionBanner();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tk.tint(tk.warning, 0.12),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: tk.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Удалённое хранится $kTrashRetentionDays дней, потом стирается.',
              style: TextStyle(fontSize: 12 * uiScale, color: tk.onMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrashRow extends StatelessWidget {
  const _TrashRow({required this.entry, required this.now});

  final MediaEntry entry;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final cubit = context.read<MediaTrashCubit>();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: 0.7,
            child: SizedBox(
              width: 50,
              height: 70,
              child: CoverImage(
                entry: entry,
                radius: AppRadii.xs,
                letterSize: 26,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.deletedAt == null
                      ? ''
                      : retentionLabel(entry.deletedAt!, now),
                  style: TextStyle(fontSize: 11 * uiScale, color: tk.onFaint),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _RestoreButton(onTap: () => cubit.restore(entry.id)),
                    const SizedBox(width: 8),
                    _DeleteSquare(onTap: () => _confirmPurge(context, cubit)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPurge(BuildContext context, MediaTrashCubit cubit) async {
    final ok = await showConfirmDeleteSheet(
      context,
      title: 'Удалить навсегда?',
      message: '«${entry.title}» будет удалена без возможности восстановления.',
    );
    if (ok) await cubit.purge(entry.id);
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: tk.tint(tk.primary, 0.14),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restore_rounded, size: 15, color: tk.primary),
              const SizedBox(width: 5),
              Text(
                'Восстановить',
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  fontWeight: FontWeight.w700,
                  color: tk.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteSquare extends StatelessWidget {
  const _DeleteSquare({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Semantics(
      button: true,
      label: 'Удалить навсегда',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: tk.tint(tk.error, 0.12),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(Icons.delete_outline_rounded, size: 18, color: tk.error),
          ),
        ),
      ),
    );
  }
}

class _EmptyTrash extends StatelessWidget {
  const _EmptyTrash();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, size: 48, color: tk.onFaint),
            const SizedBox(height: 14),
            Text('Корзина пуста', style: text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Удалённые карточки появятся здесь',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

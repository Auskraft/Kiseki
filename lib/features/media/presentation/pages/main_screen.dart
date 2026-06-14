import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/catalog/tag_repository.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/theme_picker_sheet.dart';
import '../../../../dev/demo_seed.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_repository.dart';
import '../cubit/media_list_cubit.dart';
import '../widgets/media_card.dart';
import '../widgets/mini_poster.dart';

/// Главный экран — грид картотеки + полки «Жду серии» и «Смотрю сейчас».
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MediaListCubit, MediaListState>(
          builder: (context, state) {
            if (state.loading) return const SizedBox.shrink();
            if (state.isEmpty) return const _EmptyView();
            return _HomeContent(state: state);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _snack(context, 'Форма создания карточки — следующий шаг'),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}

void _snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final MediaListState state;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final waiting = state.waiting;
    final watchingNow = state.watchingNow;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(count: state.items.length, waiting: waiting.length),
        ),
        const SliverToBoxAdapter(child: _SearchRow()),
        if (waiting.isNotEmpty)
          SliverToBoxAdapter(
            child: _Shelf(
              title: 'Жду новые серии',
              icon: Icons.hourglass_bottom_rounded,
              color: tk.statusColor(WatchStatus.paused),
              items: waiting,
            ),
          ),
        if (watchingNow.isNotEmpty)
          SliverToBoxAdapter(
            child: _Shelf(
              title: 'Смотрю сейчас',
              icon: Icons.play_arrow_rounded,
              color: tk.statusColor(WatchStatus.watching),
              items: watchingNow,
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Text('Все карточки', style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 178,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => MediaCard(
                entry: state.items[i],
                onTap: () => _snack(context, 'Детальная карточка — следующий шаг'),
              ),
              childCount: state.items.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.waiting});

  final int count;
  final int waiting;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final subtitle = waiting > 0
        ? '$count карточек · $waiting ждут серий'
        : '$count карточек';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Картотека', style: text.displaySmall),
                const SizedBox(height: 2),
                Text(subtitle, style: text.bodySmall),
              ],
            ),
          ),
          _CircleButton(
            icon: Icons.settings_outlined,
            onTap: () => showThemePicker(context),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tokens.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 20, color: context.tokens.onMuted),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: tk.surface,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: tk.outlineSoft),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: tk.onFaint),
                  const SizedBox(width: 8),
                  Text('Поиск', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tk.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: tk.outlineSoft),
            ),
            child: Icon(Icons.tune, size: 19, color: tk.onMuted),
          ),
        ],
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<MediaEntry> items;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    const miniW = 92.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: tk.tint(color, 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 9),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        SizedBox(
          height: miniW * 1.5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => MiniPoster(
              entry: items[i],
              width: miniW,
              onTap: () => _snack(context, 'Детальная карточка — следующий шаг'),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

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
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tk.primary, tk.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Картотека пуста', style: text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Добавьте первый фильм или сериал',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => _snack(context, 'Форма создания карточки — следующий шаг'),
              icon: const Icon(Icons.add),
              label: const Text('Добавить карточку'),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => seedDemoData(
                  getIt<MediaRepository>(),
                  getIt<TagRepository>(),
                ),
                icon: const Icon(Icons.science_outlined),
                label: const Text('Демо-данные (dev)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

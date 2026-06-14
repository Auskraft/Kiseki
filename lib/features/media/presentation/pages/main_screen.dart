import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/catalog/tag_repository.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../dev/demo_seed.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_repository.dart';
import '../cubit/media_list_cubit.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/media_card.dart';
import '../widgets/media_list_tile.dart';
import '../widgets/mini_poster.dart';

/// Главный экран — грид/список картотеки + полки «Жду серии»/«Смотрю сейчас»,
/// поиск, фильтр и сортировка.
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
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}

void _openEditor(BuildContext context) {
  context.push(AppRoute.editor);
}

void _openDetail(BuildContext context, String entryId) {
  context.push(AppRoute.detail(entryId));
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
        const SliverToBoxAdapter(child: _SearchBar()),
        if (state.noResults)
          const SliverToBoxAdapter(child: _NoResults())
        else ...[
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
          SliverToBoxAdapter(child: _ResultsHeader(state: state)),
          if (state.viewMode == ViewMode.grid)
            _GridSliver(items: state.items)
          else
            _ListSliver(items: state.items),
        ],
      ],
    );
  }
}

class _GridSliver extends StatelessWidget {
  const _GridSliver({required this.items});

  final List<MediaEntry> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
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
            entry: items[i],
            onTap: () => _openDetail(context, items[i].id),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _ListSliver extends StatelessWidget {
  const _ListSliver({required this.items});

  final List<MediaEntry> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: MediaListTile(
              entry: items[i],
              onTap: () => _openDetail(context, items[i].id),
            ),
          ),
          childCount: items.length,
        ),
      ),
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
            onTap: () => context.push(AppRoute.settings),
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

/// Поиск (дебаунс ~280 мс) + кнопка фильтра с точкой-индикатором.
class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: context.read<MediaListCubit>().state.query.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      context.read<MediaListCubit>().setSearch(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    context.read<MediaListCubit>().setSearch('');
  }

  Future<void> _openFilters() async {
    final cubit = context.read<MediaListCubit>();
    final result = await showFilterSheet(context, cubit.state.query);
    if (result != null) cubit.setQuery(result);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return BlocListener<MediaListCubit, MediaListState>(
      // Внешняя смена запроса (сброс фильтров) синхронизирует поле.
      listenWhen: (a, b) => a.query.text != b.query.text,
      listener: (context, state) {
        final text = state.query.text ?? '';
        if (_controller.text != text) {
          _controller.text = text;
          _controller.selection =
              TextSelection.collapsed(offset: text.length);
        }
      },
      child: Padding(
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
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: _onChanged,
                        textInputAction: TextInputAction.search,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Поиск',
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, value, _) => value.text.isEmpty
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: _clear,
                              child: Icon(Icons.close_rounded,
                                  size: 17, color: tk.onFaint),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _FilterButton(onTap: _openFilters),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final hasFilters = context
        .select<MediaListCubit, bool>((c) => c.state.query.hasFilters);
    return Material(
      color: tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.tune, size: 19, color: tk.onMuted),
              if (hasFilters)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: tk.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: tk.surface, width: 1),
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

/// Заголовок результатов: «Все карточки» / «Найдено N» + сброс + грид/список.
class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.state});

  final MediaListState state;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final filtered = state.hasSearchOrFilter;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          Text(
            filtered ? 'Найдено ${state.items.length}' : 'Все карточки',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (filtered) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.read<MediaListCubit>().resetFilters(),
              child: Text('сбросить',
                  style: TextStyle(
                      fontSize: 12 * uiScale,
                      fontWeight: FontWeight.w600,
                      color: tk.primary)),
            ),
          ],
          const Spacer(),
          _ViewToggle(mode: state.viewMode),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.mode});

  final ViewMode mode;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget btn(IconData icon, ViewMode m) {
      final active = m == mode;
      return GestureDetector(
        onTap: () => context.read<MediaListCubit>().setViewMode(m),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: active ? tk.surface2 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.xs),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon,
              size: 17, color: active ? tk.onBg : tk.onFaint),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: tk.surface3,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.grid_view_rounded, ViewMode.grid),
          const SizedBox(width: 2),
          btn(Icons.view_agenda_outlined, ViewMode.list),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tk.surface3,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 30, color: tk.onFaint),
          ),
          const SizedBox(height: 16),
          Text('Ничего не найдено', style: text.headlineSmall),
          const SizedBox(height: 6),
          Text('Попробуйте изменить запрос или фильтры',
              style: text.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => context.read<MediaListCubit>().resetFilters(),
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Сбросить фильтры'),
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
              onTap: () => _openDetail(context, items[i].id),
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
              onPressed: () => _openEditor(context),
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

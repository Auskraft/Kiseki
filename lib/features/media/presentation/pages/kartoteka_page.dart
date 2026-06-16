import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_repository.dart';
import '../cubit/live_cards_cubit.dart';
import '../widgets/domain_dropdown.dart';
import '../widgets/editor/editor_primitives.dart';
import '../widgets/media_list_tile.dart';

/// Вкладка «Картотека»: плоский список всех карточек выбранного домена с
/// быстрым фильтром по статусу (чипы). Домен — выпадашкой (Просмотр/Чтение).
class KartotekaPage extends StatelessWidget {
  const KartotekaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveCardsCubit(getIt<MediaRepository>()),
      child: const _KartotekaView(),
    );
  }
}

class _KartotekaView extends StatefulWidget {
  const _KartotekaView();

  @override
  State<_KartotekaView> createState() => _KartotekaViewState();
}

class _KartotekaViewState extends State<_KartotekaView> {
  MediaDomain _domain = MediaDomain.watch;

  /// `null` — «Все»; иначе показываем только этот статус.
  WatchStatus? _status;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Expanded(child: Text('Картотека', style: text.displaySmall)),
                  DomainDropdown(
                    domain: _domain,
                    onChanged: (d) => setState(() => _domain = d),
                  ),
                ],
              ),
            ),
            if (_domain == MediaDomain.reading)
              const Expanded(child: ReadingComingSoon())
            else
              Expanded(child: _watchBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _watchBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusFilter(
          selected: _status,
          onChanged: (s) => setState(() => _status = s),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BlocBuilder<LiveCardsCubit, LiveCardsState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.entries.isEmpty) {
                return const _Empty(text: 'Пока нет карточек');
              }
              final items = _status == null
                  ? state.entries
                  : state.entries.where((e) => e.status == _status).toList();
              if (items.isEmpty) {
                return const _Empty(text: 'В этом статусе пусто');
              }
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => MediaListTile(
                  entry: items[i],
                  onTap: () => context.push(AppRoute.detail(items[i].id)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Горизонтальная лента чипов-фильтров: «Все» + по статусу (одиночный выбор).
class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.selected, required this.onChanged});

  final WatchStatus? selected;
  final ValueChanged<WatchStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          EditorChip(
            label: 'Все',
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final s in WatchStatus.values) ...[
            const SizedBox(width: 7),
            EditorChip(
              label: StatusVisual.label(s),
              icon: StatusVisual.icon(s),
              accent: tk.statusColor(s),
              selected: selected == s,
              onTap: () => onChanged(selected == s ? null : s),
            ),
          ],
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 44, color: tk.onFaint),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

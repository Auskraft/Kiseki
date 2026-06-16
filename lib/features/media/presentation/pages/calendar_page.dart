import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_repository.dart';
import '../cubit/live_cards_cubit.dart';
import '../widgets/domain_dropdown.dart';

const List<String> _months = [
  'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', //
  'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
];

// Месяц как одно число (year*12 + month-1) — удобно сравнивать и перебирать.
int _ym(DateTime d) => d.year * 12 + (d.month - 1);
int _ymFor(int year, int month) => year * 12 + (month - 1);
int _ymYear(int ym) => ym ~/ 12;
int _ymMonth(int ym) => ym % 12 + 1;
String _ymLabel(int ym) => '${_months[_ymMonth(ym) - 1]} ${_ymYear(ym)}';

/// Период карточки на оси месяцев. `null` — нет ни одной даты (в таймлайн не
/// помещается, идёт в блок «Без дат»). «Смотрю» без финала тянется до текущего
/// месяца.
({int start, int end})? _spanOf(MediaEntry e, int nowYm) {
  final ds = <int>[
    if (e.startedAt != null) _ym(e.startedAt!.value),
    if (e.lastActivityAt != null) _ym(e.lastActivityAt!.value),
    if (e.finishedAt != null) _ym(e.finishedAt!.value),
  ];
  if (ds.isEmpty) return null;
  final start = ds.reduce(min);
  var end = ds.reduce(max);
  if (e.status == WatchStatus.watching && e.finishedAt == null) {
    end = max(end, nowYm);
  }
  return (start: start, end: max(end, start));
}

enum _View { calendar, gantt }

/// Вкладка «Календарь»: помесячный таймлайн просмотров (цвет = статус) +
/// переключение на Гант («что за чем»). Сверху — выпадашка домена.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveCardsCubit(getIt<MediaRepository>()),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView();

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  MediaDomain _domain = MediaDomain.watch;
  _View _view = _View.calendar;

  static const double _titleWidth = 116;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(domain: _domain, onDomain: (d) => setState(() => _domain = d)),
            Expanded(child: _watchBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _watchBody(BuildContext context) {
    return BlocBuilder<LiveCardsCubit, LiveCardsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final nowYm = _ym(DateTime.now());
        final dated = <(MediaEntry, ({int start, int end}))>[];
        final undated = <MediaEntry>[];
        for (final e in state.entries) {
          final s = _spanOf(e, nowYm);
          if (s == null) {
            undated.add(e);
          } else {
            dated.add((e, s));
          }
        }

        if (state.entries.isEmpty) {
          return const _EmptyState();
        }

        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
              child: _ViewToggle(
                view: _view,
                onChanged: (v) => setState(() => _view = v),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _Legend(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 24),
                children: [
                  if (dated.isEmpty)
                    _hint('Ни у одной карточки нет дат просмотра — задай их в '
                        'карточке, чтобы увидеть таймлайн.')
                  else if (_view == _View.calendar)
                    ..._timeline(dated)
                  else
                    ..._gantt(dated),
                  if (undated.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _UndatedSection(entries: undated),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Помесячный таймлайн ──────────────────────────────────────────────────

  List<Widget> _timeline(List<(MediaEntry, ({int start, int end}))> dated) {
    final byMonth = <int, List<MediaEntry>>{};
    for (final (e, s) in dated) {
      for (var ym = s.start; ym <= s.end; ym++) {
        (byMonth[ym] ??= []).add(e);
      }
    }
    final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final ym in months) _MonthBlock(label: _ymLabel(ym), entries: byMonth[ym]!),
    ];
  }

  // ── Гант ─────────────────────────────────────────────────────────────────

  List<Widget> _gantt(List<(MediaEntry, ({int start, int end}))> dated) {
    final rows = [...dated]..sort((a, b) {
        final c = a.$2.start.compareTo(b.$2.start);
        return c != 0 ? c : a.$2.end.compareTo(b.$2.end);
      });
    final rangeStart = dated.map((d) => d.$2.start).reduce(min);
    final rangeEnd = dated.map((d) => d.$2.end).reduce(max);
    return [
      _GanttAxis(rangeStart: rangeStart, rangeEnd: rangeEnd, titleWidth: _titleWidth),
      for (final (e, s) in rows)
        _GanttRow(
          entry: e,
          span: s,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          titleWidth: _titleWidth,
        ),
    ];
  }

  Widget _hint(String text) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13 * uiScale, color: tk.onMuted, height: 1.4),
      ),
    );
  }
}

// ─────────────────────────── шапка ───────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.domain, required this.onDomain});

  final MediaDomain domain;
  final ValueChanged<MediaDomain> onDomain;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text('Календарь', style: text.displaySmall)),
          // «Жидкость» в календаре показана, но неактивна (нет дат-таймлайна).
          DomainDropdown(
            domain: domain,
            onChanged: onDomain,
            enabled: const {MediaDomain.watch},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── переключатель вида ──────────────────────────────

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.view, required this.onChanged});

  final _View view;
  final ValueChanged<_View> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget seg(_View v, IconData icon, String label) {
      final sel = v == view;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (sel) return;
            HapticFeedback.selectionClick();
            onChanged(v);
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? tk.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: sel ? Border.all(color: tk.outlineSoft) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: sel ? tk.primary : tk.onMuted),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13 * uiScale,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                    color: sel ? tk.primary : tk.onMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          seg(_View.calendar, Icons.calendar_view_month_rounded, 'Календарь'),
          const SizedBox(width: 4),
          seg(_View.gantt, Icons.view_timeline_rounded, 'Гант'),
        ],
      ),
    );
  }
}

// ─────────────────────────── легенда ─────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final s in WatchStatus.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tk.statusColor(s),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                StatusVisual.label(s),
                style: TextStyle(fontSize: 11 * uiScale, color: tk.onMuted),
              ),
            ],
          ),
      ],
    );
  }
}

// ─────────────────────── месяц (таймлайн) ────────────────────────────────

class _MonthBlock extends StatelessWidget {
  const _MonthBlock({required this.label, required this.entries});

  final String label;
  final List<MediaEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5 * uiScale,
              fontWeight: FontWeight.w700,
              color: tk.onBg,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [for (final e in entries) _SeriesChip(entry: e)],
          ),
        ],
      ),
    );
  }
}

class _SeriesChip extends StatelessWidget {
  const _SeriesChip({required this.entry});

  final MediaEntry entry;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final c = tk.statusColor(entry.status);
    return Material(
      color: tk.tint(c, 0.16),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: () => context.push(AppRoute.detail(entry.id)),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: c.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190),
                child: Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5 * uiScale,
                    fontWeight: FontWeight.w600,
                    color: tk.onBg,
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

// ─────────────────────────── Гант ────────────────────────────────────────

class _GanttAxis extends StatelessWidget {
  const _GanttAxis({
    required this.rangeStart,
    required this.rangeEnd,
    required this.titleWidth,
  });

  final int rangeStart;
  final int rangeEnd;
  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: titleWidth),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, cns) {
                final w = cns.maxWidth;
                final total = rangeEnd - rangeStart + 1;
                final children = <Widget>[];
                for (var y = _ymYear(rangeStart); y <= _ymYear(rangeEnd); y++) {
                  final raw = _ymFor(y, 1);
                  final tickYm = raw < rangeStart
                      ? rangeStart
                      : (raw > rangeEnd ? rangeEnd : raw);
                  final left = (tickYm - rangeStart) / total * w;
                  children.add(Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 1, color: tk.outlineSoft),
                  ));
                  children.add(Positioned(
                    left: left + 3,
                    top: 1,
                    child: Text(
                      '$y',
                      style: TextStyle(
                        fontSize: 10 * uiScale,
                        fontWeight: FontWeight.w700,
                        color: tk.onMuted,
                      ),
                    ),
                  ));
                }
                return SizedBox(
                  height: 16,
                  child: Stack(clipBehavior: Clip.none, children: children),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttRow extends StatelessWidget {
  const _GanttRow({
    required this.entry,
    required this.span,
    required this.rangeStart,
    required this.rangeEnd,
    required this.titleWidth,
  });

  final MediaEntry entry;
  final ({int start, int end}) span;
  final int rangeStart;
  final int rangeEnd;
  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final c = tk.statusColor(entry.status);
    return InkWell(
      onTap: () => context.push(AppRoute.detail(entry.id)),
      borderRadius: BorderRadius.circular(AppRadii.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: titleWidth,
              child: Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: tk.onBg,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, cns) {
                  final w = cns.maxWidth;
                  final total = rangeEnd - rangeStart + 1;
                  final left = (span.start - rangeStart) / total * w;
                  final rawW = (span.end - span.start + 1) / total * w;
                  final barW = rawW.clamp(8.0, max(8.0, w - left)).toDouble();
                  return SizedBox(
                    height: 22,
                    child: Stack(
                      children: [
                        Positioned(
                          left: left,
                          top: 2,
                          bottom: 2,
                          width: barW,
                          child: Container(
                            decoration: BoxDecoration(
                              color: tk.tint(c, 0.30),
                              borderRadius: BorderRadius.circular(AppRadii.xs),
                              border: Border.all(color: c.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ─────────────────────── без дат / пусто ─────────────────────────────────

class _UndatedSection extends StatelessWidget {
  const _UndatedSection({required this.entries});

  final List<MediaEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_busy_rounded, size: 16, color: tk.onFaint),
            const SizedBox(width: 7),
            Text(
              'Без дат',
              style: TextStyle(
                fontSize: 13 * uiScale,
                fontWeight: FontWeight.w700,
                color: tk.onMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [for (final e in entries) _SeriesChip(entry: e)],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, size: 48, color: tk.onFaint),
            const SizedBox(height: 14),
            Text(
              'Пока нет карточек',
              style: TextStyle(
                fontSize: 15 * uiScale,
                fontWeight: FontWeight.w700,
                color: tk.onBg,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Добавь просмотры с датами — они появятся на таймлайне.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13 * uiScale, color: tk.onMuted),
            ),
          ],
        ),
      ),
    );
  }
}

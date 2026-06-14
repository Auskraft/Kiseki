import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/catalog/catalog_date.dart';
import '../../../../core/catalog/date_precision.dart';
import '../../../../core/catalog/tag.dart';
import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/catalog_date_format.dart';
import '../../../../core/ui/hex_color.dart';
import '../../../../core/ui/score_badge.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_repository.dart';
import '../cubit/media_detail_cubit.dart';
import '../widgets/cover_image.dart';
import '../widgets/status_change_sheet.dart';

/// Экран 02 — детальная карточка медиа. Реактивно следит за записью и даёт
/// быстрые действия (смена статуса, избранное, +1 пересмотр, правка, корзина).
class MediaDetailPage extends StatelessWidget {
  const MediaDetailPage({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MediaDetailCubit(getIt<MediaRepository>(), entryId),
      child: BlocBuilder<MediaDetailCubit, MediaDetailState>(
        builder: (context, state) {
          if (state.loading) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          final entry = state.entry;
          if (entry == null) return const _NotFound();
          return _DetailView(entry: entry);
        },
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Карточка не найдена',
            style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.entry});

  final MediaEntry entry;

  bool get _waiting =>
      entry.status == WatchStatus.paused &&
      entry.unfinishedReason == UnfinishedReason.waitingEpisodes;

  Future<void> _changeStatus(BuildContext context) async {
    final cubit = context.read<MediaDetailCubit>();
    final choice = await showStatusSheet(
      context,
      current: entry.status,
      currentReason: entry.unfinishedReason,
      episodic: entry.isEpisodic,
    );
    if (choice != null) {
      await cubit.setStatus(choice.status, reason: choice.reason);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final router = GoRouter.of(context);
    await context.read<MediaDetailCubit>().softDelete();
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Cover(entry: entry),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusButton(
                  entry: entry,
                  waiting: _waiting,
                  onTap: () => _changeStatus(context),
                ),
                const SizedBox(height: 16),
                _RatingBlock(value: entry.rating?.value),
                if (entry.isEpisodic) ...[
                  const SizedBox(height: 16),
                  _ProgressBlock(entry: entry, waiting: _waiting),
                ],
                const SizedBox(height: 16),
                _DatesRow(entry: entry),
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _TagsWrap(tags: entry.tags),
                ],
                if ((entry.note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _NoteCard(note: entry.note!.trim()),
                ],
                const SizedBox(height: 16),
                _MetaRow(
                  count: entry.rewatchCount,
                  onPlus: () => context.read<MediaDetailCubit>().incrementEvent(),
                ),
                const SizedBox(height: 22),
                _Actions(
                  onEdit: () => context.push(AppRoute.edit(entry.id)),
                  onDelete: () => _delete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── обложка ─────────────────────────────────────

class _Cover extends StatelessWidget {
  const _Cover({required this.entry});

  final MediaEntry entry;

  String get _meta {
    final parts = <String>[
      if (entry.year != null) '${entry.year}',
      if (entry.country != null) entry.country!,
      entry.mediaType.label,
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 248 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CoverImage(
            entry: entry,
            full: true,
            radius: 0,
            letterSize: 150,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.transparent, Color(0xCC000000)],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, topInset + 8, 14, 0),
            child: Row(
              children: [
                _GlassButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _GlassButton(
                  icon: entry.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border_rounded,
                  iconColor: entry.isFavorite ? const Color(0xFFFF7BA3) : null,
                  onTap: () => context.read<MediaDetailCubit>().toggleFavorite(),
                ),
                const SizedBox(width: 8),
                _MoreButton(entry: entry),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.displaySmall?.copyWith(
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                if ((entry.originalTitle ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    entry.originalTitle!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  _meta,
                  style: text.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
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

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.32),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: iconColor ?? Colors.white),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.entry});

  final MediaEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.32),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz_rounded, size: 20, color: Colors.white),
        padding: const EdgeInsets.all(8),
        onSelected: (v) {
          final cubit = context.read<MediaDetailCubit>();
          if (v == 'edit') {
            context.push(AppRoute.edit(entry.id));
          } else if (v == 'trash') {
            final router = GoRouter.of(context);
            cubit.softDelete().then((_) => router.pop());
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Редактировать')),
          PopupMenuItem(value: 'trash', child: Text('В корзину')),
        ],
      ),
    );
  }
}

// ─────────────────────────── статус ──────────────────────────────────────

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.entry,
    required this.waiting,
    required this.onTap,
  });

  final MediaEntry entry;
  final bool waiting;
  final VoidCallback onTap;

  String get _label {
    final base = StatusVisual.label(entry.status, waiting: waiting);
    final reason = entry.unfinishedReason;
    if (reason != null && reason != UnfinishedReason.waitingEpisodes) {
      return '$base · ${reasonLabel(reason)}';
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = tk.statusColor(waiting ? WatchStatus.paused : entry.status);
    return Material(
      color: tk.tint(color, 0.14),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(StatusVisual.icon(entry.status, waiting: waiting),
                  size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text('сменить',
                  style: TextStyle(
                      fontSize: 12 * uiScale,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.9))),
              Icon(Icons.expand_more_rounded, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── оценка ──────────────────────────────────────

class _RatingBlock extends StatelessWidget {
  const _RatingBlock({required this.value});

  final int? value;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    if (value == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('—',
              style: GoogleFonts.onest(
                  fontSize: 40 * uiScale,
                  fontWeight: FontWeight.w800,
                  color: tk.onFaint)),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('не оценено',
                style: TextStyle(fontSize: 13 * uiScale, color: tk.onFaint)),
          ),
        ],
      );
    }

    final color = tk.scoreColor(value!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('${value!}',
                style: GoogleFonts.onest(
                  fontSize: 40 * uiScale,
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
            const SizedBox(width: 4),
            Text('/ 100',
                style: TextStyle(
                    fontSize: 14 * uiScale,
                    fontWeight: FontWeight.w600,
                    color: tk.onFaint)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(scoreLabel(value!),
                    style: TextStyle(
                        fontSize: 13 * uiScale,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text('моя оценка',
                    style: TextStyle(
                        fontSize: 11 * uiScale, color: tk.onFaint)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ScoreBar(value: value!, color: color),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return LayoutBuilder(
      builder: (context, c) {
        final fraction = (value / 100).clamp(0.0, 1.0);
        return SizedBox(
          height: 22,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: tk.surface3,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              Positioned(
                left: (c.maxWidth - 22) * fraction,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: tk.surface2,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── прогресс серий ──────────────────────────────

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.entry, required this.waiting});

  final MediaEntry entry;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = tk.statusColor(waiting ? WatchStatus.paused : entry.status);
    final season = entry.currentSeason;
    final episode = entry.currentEpisode;
    final totalEp = entry.totalEpisodes;
    final multiSeason = (entry.totalSeasons ?? 1) > 1;
    final showBar = totalEp != null && episode != null && !multiSeason;

    final seasonLine = season == null
        ? null
        : 'сезон $season${entry.totalSeasons != null ? ' из ${entry.totalSeasons}' : ''}';
    final epLabel = episode == null
        ? '—'
        : 'S${season ?? 1} · E$episode';
    final countLine = (totalEp != null && episode != null)
        ? '$episode / $totalEp серий'
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Прогресс серий',
                  style: TextStyle(
                      fontSize: 13 * uiScale,
                      fontWeight: FontWeight.w700,
                      color: tk.onBg)),
              if (seasonLine != null)
                Text(seasonLine,
                    style: TextStyle(
                        fontSize: 11.5 * uiScale, color: tk.onMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(epLabel,
                  style: TextStyle(
                    fontFamily: 'Unbounded',
                    fontVariations: const [FontVariation('wght', 600)],
                    fontSize: 19 * uiScale,
                    color: tk.onBg,
                  )),
              const Spacer(),
              if (countLine != null)
                Text(countLine,
                    style: TextStyle(
                        fontSize: 12.5 * uiScale,
                        fontWeight: FontWeight.w600,
                        color: tk.onMuted)),
            ],
          ),
          if (showBar) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: (episode / totalEp).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: tk.surface3,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────── даты ────────────────────────────────────────

class _DatesRow extends StatelessWidget {
  const _DatesRow({required this.entry});

  final MediaEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _DateCell(label: 'Начал', date: entry.startedAt)),
        const SizedBox(width: 9),
        Expanded(
            child: _DateCell(label: 'Последний', date: entry.lastActivityAt)),
        const SizedBox(width: 9),
        Expanded(child: _DateCell(label: 'Досмотрел', date: entry.finishedAt)),
      ],
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({required this.label, required this.date});

  final String label;
  final CatalogDate? date;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final approx = date != null && date!.precision != DatePrecision.day;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10.5 * uiScale, color: tk.onFaint)),
          const SizedBox(height: 4),
          Text(
            date == null ? '—' : formatCatalogDate(date!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5 * uiScale,
              fontWeight: FontWeight.w600,
              fontStyle: approx ? FontStyle.italic : FontStyle.normal,
              color: date == null ? tk.onFaint : tk.onBg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── теги ────────────────────────────────────────

class _TagsWrap extends StatelessWidget {
  const _TagsWrap({required this.tags});

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: tk.surface,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: tk.outlineSoft),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: parseHexColor(tag.color) ?? tk.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(tag.name,
                    style: TextStyle(
                        fontSize: 12 * uiScale,
                        fontWeight: FontWeight.w600,
                        color: tk.onBg)),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────── отзыв ───────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('МОЙ ОТЗЫВ',
              style: TextStyle(
                fontSize: 10 * uiScale,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: tk.onFaint,
              )),
          const SizedBox(height: 8),
          Text(
            note,
            style: TextStyle(
              fontSize: 14 * uiScale,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: tk.onBg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── мета (пересмотры) ───────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.count, required this.onPlus});

  final int count;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: [
        Icon(Icons.repeat_rounded, size: 16, color: tk.onMuted),
        const SizedBox(width: 8),
        Text('Пересмотров: $count',
            style: TextStyle(
                fontSize: 13 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onBg)),
        const Spacer(),
        Material(
          color: tk.tint(tk.primary, 0.14),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: InkWell(
            onTap: onPlus,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 15, color: tk.primary),
                  const SizedBox(width: 3),
                  Text('1 просмотр',
                      style: TextStyle(
                          fontSize: 12 * uiScale,
                          fontWeight: FontWeight.w700,
                          color: tk.primary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── действия ────────────────────────────────────

class _Actions extends StatelessWidget {
  const _Actions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Редактировать'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: tk.tint(tk.error, 0.12),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.delete_outline_rounded, color: tk.error),
            ),
          ),
        ),
      ],
    );
  }
}

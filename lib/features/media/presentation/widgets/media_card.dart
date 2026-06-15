import 'package:flutter/material.dart';

import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/poster_overlays.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_entry.dart';
import 'cover_image.dart';

/// Карточка медиа в гриде: постер (заполняет ячейку) + значки (статус, оценка,
/// избранное, прогресс) + название и подзаголовок «год · тип».
class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.entry, this.onTap});

  final MediaEntry entry;
  final VoidCallback? onTap;

  bool get _waiting =>
      entry.status == WatchStatus.paused &&
      entry.unfinishedReason == UnfinishedReason.waitingEpisodes;

  bool get _showProgress =>
      entry.isEpisodic &&
      entry.totalEpisodes != null &&
      entry.totalEpisodes! > 0 &&
      (entry.totalSeasons ?? 1) <= 1 &&
      entry.currentEpisode != null;

  String get _subtitle {
    final parts = <String>[
      if (entry.year != null) '${entry.year}',
      entry.mediaType.labelFor(entry.format),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CoverImage(entry: entry),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: StatusSquare(status: entry.status, waiting: _waiting, size: 22),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: PosterScoreBadge(value: entry.rating?.value),
                  ),
                  if (entry.isFavorite)
                    const Positioned(bottom: 6, left: 6, child: FavHeart()),
                  if (_showProgress)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: PosterProgressBar(
                        fraction: entry.currentEpisode! / entry.totalEpisodes!,
                        color: context.tokens.statusColor(
                            _waiting ? WatchStatus.paused : entry.status),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(entry.title,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleSmall),
          const SizedBox(height: 1),
          Text(_subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: text.bodySmall),
        ],
      ),
    );
  }
}

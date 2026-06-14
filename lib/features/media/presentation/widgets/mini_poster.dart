import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/ui/poster_overlays.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_entry.dart';
import 'cover_image.dart';

/// Компактный постер для горизонтальных полок. Заполняет высоту, заданную
/// полкой (используется внутри height-bounded горизонтального списка).
class MiniPoster extends StatelessWidget {
  const MiniPoster({super.key, required this.entry, required this.width, this.onTap});

  final MediaEntry entry;
  final double width;
  final VoidCallback? onTap;

  bool get _waiting =>
      entry.status == WatchStatus.paused &&
      entry.unfinishedReason == UnfinishedReason.waitingEpisodes;

  String? get _episodeLabel {
    if (!entry.isEpisodic || entry.currentEpisode == null) return null;
    if (entry.currentSeason != null) {
      return 'S${entry.currentSeason} · E${entry.currentEpisode}';
    }
    return 'E${entry.currentEpisode}';
  }

  @override
  Widget build(BuildContext context) {
    final episode = _episodeLabel;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CoverImage(entry: entry, letterSize: 44),
              Positioned(
                top: 5,
                left: 5,
                child: StatusSquare(status: entry.status, waiting: _waiting, size: 18),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: PosterScoreBadge(value: entry.rating?.value, fontSize: 11),
              ),
              if (episode != null)
                Positioned(
                  left: 5,
                  right: 5,
                  bottom: 5,
                  child: _EpisodePill(label: episode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodePill extends StatelessWidget {
  const _EpisodePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          alignment: Alignment.center,
          color: Colors.black.withValues(alpha: 0.42),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.onest(
              fontSize: 10.5 * uiScale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

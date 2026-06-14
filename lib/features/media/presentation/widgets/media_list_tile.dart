import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_entry.dart';
import 'cover_image.dart';

/// Строка списочного вида (макет 01b): thumbnail + название/мета/статус +
/// крупная оценка справа.
class MediaListTile extends StatelessWidget {
  const MediaListTile({super.key, required this.entry, this.onTap});

  final MediaEntry entry;
  final VoidCallback? onTap;

  bool get _waiting =>
      entry.status == WatchStatus.paused &&
      entry.unfinishedReason == UnfinishedReason.waitingEpisodes;

  String get _subtitle {
    final parts = <String>[
      if ((entry.originalTitle ?? '').trim().isNotEmpty) entry.originalTitle!.trim(),
      if (entry.year != null) '${entry.year}',
      entry.mediaType.label,
    ];
    return parts.join(' · ');
  }

  String? get _progress {
    if (!entry.isEpisodic || entry.currentEpisode == null) return null;
    final s = entry.currentSeason;
    return s != null ? 'S$s · E${entry.currentEpisode}' : 'E${entry.currentEpisode}';
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    final rating = entry.rating?.value;
    return Material(
      color: tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 70,
                child: CoverImage(
                  entry: entry,
                  radius: AppRadii.xs,
                  letterSize: 26,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall,
                          ),
                        ),
                        if (entry.isFavorite) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.favorite,
                              size: 12, color: Color(0xFFE0608A)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: tk.onFaint),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        StatusChip(status: entry.status, waiting: _waiting),
                        if (_progress != null) ...[
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              _progress!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelSmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _Score(value: rating),
            ],
          ),
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.value});

  final int? value;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    if (value == null) {
      return Text('—',
          style: GoogleFonts.onest(
              fontSize: 17 * uiScale,
              fontWeight: FontWeight.w800,
              color: tk.onFaint));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$value',
            style: GoogleFonts.onest(
              fontSize: 18 * uiScale,
              fontWeight: FontWeight.w800,
              color: tk.scoreColor(value!),
              fontFeatures: const [FontFeature.tabularFigures()],
            )),
        Text(' /100',
            style: TextStyle(
                fontSize: 10 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onFaint)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/images/media_paths.dart';
import '../../../../core/images/media_spec.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/media_entry.dart';
import 'poster_placeholder.dart';

/// Обложка карточки: реальная картинка (если файл на диске есть) либо
/// плейсхолдер по типу/названию (нет картинки / файл потерян — без краша).
/// `full` — крупный размер (деталь), иначе thumb (списки).
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.entry,
    this.full = false,
    this.radius = AppRadii.md,
    this.letterSize = 64,
  });

  final MediaEntry entry;
  final bool full;
  final double radius;
  final double letterSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = PosterPlaceholder(
      type: entry.mediaType,
      title: entry.title,
      radius: radius,
      letterSize: letterSize,
    );

    final cover = entry.cover;
    if (cover == null || !getIt.isRegistered<MediaPaths>()) return placeholder;

    final paths = getIt<MediaPaths>();
    final file = full ? paths.absFull(cover.id) : paths.absThumb(cover.id);
    if (!file.existsSync()) return placeholder; // файл потерян

    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth:
            ((full ? MediaSpec.fullEdge : MediaSpec.thumbEdge) * dpr).round(),
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

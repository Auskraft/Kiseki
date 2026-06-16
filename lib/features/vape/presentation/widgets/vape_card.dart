import 'package:flutter/material.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/images/media_paths.dart';
import '../../../../core/images/media_spec.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/poster_overlays.dart';
import '../../domain/vape_entry.dart';

/// Карточка жидкости в гриде Главной — постер-аналог `MediaCard`: фото упаковки
/// заполняет ячейку, бейдж-капля (домен) слева, общая оценка справа, снизу
/// название вкуса + «бренд · тип».
class VapeCard extends StatelessWidget {
  const VapeCard({super.key, required this.entry, this.onTap});

  final VapeEntry entry;
  final VoidCallback? onTap;

  String get _subtitle => '${entry.brand} · ${entry.nicotineType.label}';

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
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
                  _Cover(entry: entry),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tk.secondary,
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: const Icon(Icons.water_drop_rounded,
                          size: 13, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: PosterScoreBadge(value: entry.rating),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(entry.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall),
          const SizedBox(height: 1),
          Text(_subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.entry});

  final VapeEntry entry;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget placeholder() => Container(
          color: tk.tint(tk.secondary, 0.16),
          alignment: Alignment.center,
          child: Icon(Icons.water_drop_rounded, size: 34, color: tk.secondary),
        );

    final cover = entry.cover;
    if (cover == null || !getIt.isRegistered<MediaPaths>()) return placeholder();
    final file = getIt<MediaPaths>().absFull(cover.id);
    if (!file.existsSync()) return placeholder();

    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: (MediaSpec.fullEdge * dpr).round(),
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => placeholder(),
    );
  }
}

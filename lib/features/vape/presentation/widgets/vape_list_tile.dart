import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/images/media_paths.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/vape_entry.dart';

/// Строка списка жидкости: фото + название вкуса/мета (бренд·тип·крепость) +
/// общая оценка справа. Перекликается с `MediaListTile`.
class VapeListTile extends StatelessWidget {
  const VapeListTile({super.key, required this.entry, this.onTap});

  final VapeEntry entry;
  final VoidCallback? onTap;

  String get _subtitle {
    final parts = <String>[
      entry.brand,
      entry.nicotineType.label,
      '${entry.nicotineStrength} мг',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
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
              _Thumb(entry: entry),
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
                        if (entry.canRebuy) ...[
                          const SizedBox(width: 5),
                          Icon(Icons.replay_rounded,
                              size: 13, color: tk.success),
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
                    if (entry.flavorCategory != null) ...[
                      const SizedBox(height: 6),
                      _CategoryChip(label: entry.flavorCategory!.label),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _Score(value: entry.rating),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.entry});

  final VapeEntry entry;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final cover = entry.cover;
    return SizedBox(
      width: 50,
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xs),
        child: cover == null
            ? Container(
                color: tk.tint(tk.secondary, 0.16),
                alignment: Alignment.center,
                child: Icon(Icons.water_drop_rounded,
                    color: tk.secondary, size: 22),
              )
            : Image.file(
                getIt<MediaPaths>().absFull(cover.id),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Container(
                  color: tk.surface3,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined,
                      color: tk.onFaint, size: 20),
                ),
              ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tk.tint(tk.secondary, 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: tk.secondary, fontWeight: FontWeight.w700),
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
        Text((value! / 10).toStringAsFixed(1),
            style: GoogleFonts.onest(
              fontSize: 18 * uiScale,
              fontWeight: FontWeight.w800,
              color: tk.scoreColor(value!),
            )),
        Text(' /10',
            style: TextStyle(
                fontSize: 10 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onFaint)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Скелетон-сетка на время загрузки списка (вместо пустого экрана).
/// Статичные плейсхолдеры в цвете темы — без анимации: мгновенные локальные
/// загрузки не успевают мигнуть, а на больших объёмах сразу задают форму
/// контента. Шиммер — на усмотрение владельца (визуальная полировка).
class MediaGridSkeleton extends StatelessWidget {
  const MediaGridSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.surface3;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 178,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.58,
      ),
      itemCount: count,
      itemBuilder: (_, _) => _SkeletonCard(color: color),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    BoxDecoration deco(double radius) => BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: DecoratedBox(decoration: deco(AppRadii.md))),
        const SizedBox(height: 8),
        Container(height: 11, decoration: deco(AppRadii.xs)),
        const SizedBox(height: 5),
        Container(height: 9, width: 70, decoration: deco(AppRadii.xs)),
      ],
    );
  }
}

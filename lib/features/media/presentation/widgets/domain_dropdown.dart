import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';

/// Домен картотеки. «Чтение» — будущая фича (книги/манга), пока заглушка.
enum MediaDomain { watch, reading }

String mediaDomainLabel(MediaDomain d) =>
    d == MediaDomain.watch ? 'Просмотр' : 'Чтение';

IconData mediaDomainIcon(MediaDomain d) =>
    d == MediaDomain.watch ? Icons.smart_display_rounded : Icons.menu_book_rounded;

/// Выпадашка выбора домена (Просмотр/Чтение) — общая для вкладок Календарь и
/// Картотека. Пилюля с иконкой+подписью, меню по тапу.
class DomainDropdown extends StatelessWidget {
  const DomainDropdown({super.key, required this.domain, required this.onChanged});

  final MediaDomain domain;
  final ValueChanged<MediaDomain> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return PopupMenuButton<MediaDomain>(
      initialValue: domain,
      tooltip: 'Раздел',
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final d in MediaDomain.values)
          PopupMenuItem<MediaDomain>(
            value: d,
            child: Row(
              children: [
                Icon(mediaDomainIcon(d), size: 19, color: tk.onMuted),
                const SizedBox(width: 10),
                Text(mediaDomainLabel(d)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: tk.surface2,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: tk.outlineSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(mediaDomainIcon(domain), size: 17, color: tk.primary),
            const SizedBox(width: 7),
            Text(
              mediaDomainLabel(domain),
              style: TextStyle(
                fontSize: 13 * uiScale,
                fontWeight: FontWeight.w700,
                color: tk.onBg,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, size: 20, color: tk.onMuted),
          ],
        ),
      ),
    );
  }
}

/// Заглушка раздела «Чтение» (книги/манга — будущий домен картотеки).
class ReadingComingSoon extends StatelessWidget {
  const ReadingComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 48, color: tk.onFaint),
            const SizedBox(height: 14),
            Text(
              'Чтение — скоро',
              style: TextStyle(
                fontSize: 15 * uiScale,
                fontWeight: FontWeight.w700,
                color: tk.onBg,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Книги и манга появятся отдельным разделом картотеки.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13 * uiScale, color: tk.onMuted),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';

/// Домен картотеки для выпадашки: «Просмотр» (медиа) и «Жидкость» (вейп).
enum MediaDomain { watch, vape }

String mediaDomainLabel(MediaDomain d) =>
    d == MediaDomain.watch ? 'Просмотр' : 'Жидкость';

IconData mediaDomainIcon(MediaDomain d) =>
    d == MediaDomain.watch ? Icons.smart_display_rounded : Icons.water_drop_rounded;

/// Выпадашка выбора домена — общая для вкладок Календарь и Картотека. Пилюля с
/// иконкой+подписью, меню по тапу. [enabled] — какие домены выбираемы (в
/// Календаре «Жидкость» показана, но неактивна).
class DomainDropdown extends StatelessWidget {
  const DomainDropdown({
    super.key,
    required this.domain,
    required this.onChanged,
    this.enabled = const {MediaDomain.watch, MediaDomain.vape},
  });

  final MediaDomain domain;
  final ValueChanged<MediaDomain> onChanged;
  final Set<MediaDomain> enabled;

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
            enabled: enabled.contains(d),
            child: Row(
              children: [
                Icon(mediaDomainIcon(d),
                    size: 19,
                    color: enabled.contains(d) ? tk.onMuted : tk.onFaint),
                const SizedBox(width: 10),
                Text(
                  mediaDomainLabel(d),
                  style: TextStyle(
                      color: enabled.contains(d) ? null : tk.onFaint),
                ),
                if (!enabled.contains(d)) ...[
                  const SizedBox(width: 8),
                  Text('скоро',
                      style: TextStyle(fontSize: 11 * uiScale, color: tk.onFaint)),
                ],
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

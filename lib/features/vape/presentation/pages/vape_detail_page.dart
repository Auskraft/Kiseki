import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/images/media_paths.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/catalog_date_format.dart';
import '../../../../core/ui/confirm_sheet.dart';
import '../../domain/vape_entry.dart';
import '../../domain/vape_repository.dart';
import 'vape_editor_page.dart';

/// Экран детали жидкости (read-view, реактивно). Правка — открывает редактор-шит;
/// удаление — мягкое (в корзину), с подтверждением.
class VapeDetailPage extends StatelessWidget {
  const VapeDetailPage({super.key, required this.entryId});

  final String entryId;

  Future<void> _delete(BuildContext context) async {
    final ok = await showConfirmDeleteSheet(
      context,
      title: 'Удалить жидкость?',
      message: 'Запись будет удалена из картотеки.',
      confirmLabel: 'Удалить',
    );
    if (!ok || !context.mounted) return;
    await getIt<VapeRepository>().softDelete(entryId);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return StreamBuilder<VapeEntry?>(
      stream: getIt<VapeRepository>().watchById(entryId),
      builder: (context, snap) {
        final e = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(e?.title ?? 'Жидкость'),
            actions: [
              if (e != null) ...[
                IconButton(
                  tooltip: 'Изменить',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => openVapeEditor(context, entryId: entryId),
                ),
                IconButton(
                  tooltip: 'Удалить',
                  icon: Icon(Icons.delete_outline_rounded, color: tk.error),
                  onPressed: () => _delete(context),
                ),
              ],
            ],
          ),
          body: e == null
              ? (snap.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : const _NotFound())
              : _Body(entry: e),
        );
      },
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Запись не найдена'));
}

class _Body extends StatelessWidget {
  const _Body({required this.entry});

  final VapeEntry entry;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    final cover = entry.cover;
    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        if (cover != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Image.file(
              getIt<MediaPaths>().absFull(cover.id),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        if (cover != null) const SizedBox(height: 16),
        Text(entry.title, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(entry.brand,
            style: text.bodyLarge?.copyWith(color: tk.onMuted)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(label: entry.nicotineType.label, color: tk.primary),
            _Chip(label: '${entry.nicotineStrength} мг/мл', color: tk.primary),
            if (entry.flavorCategory != null)
              _Chip(label: entry.flavorCategory!.label, color: tk.secondary),
          ],
        ),
        const SizedBox(height: 16),
        if (entry.addedAt != null)
          _InfoRow(
            icon: Icons.event_rounded,
            label: 'Добавлено',
            value: formatCatalogDate(entry.addedAt!),
          ),
        const SizedBox(height: 8),
        _ToggleInfo(label: 'Можно покупать снова', value: entry.canRebuy),
        _ToggleInfo(label: 'Мылится вкус', value: entry.flavorFades),
        _ToggleInfo(
            label: 'Портит вату/картридж/испаритель',
            value: entry.damagesHardware),
        const SizedBox(height: 18),
        _RatingsCard(entry: entry),
        if ((entry.flavorDescription ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _Section(title: 'Описание вкуса', body: entry.flavorDescription!),
        ],
        if ((entry.note ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _Section(title: 'Комментарий', body: entry.note!),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tk.tint(color, 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12.5 * uiScale,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      children: [
        Icon(icon, size: 18, color: tk.onMuted),
        const SizedBox(width: 10),
        Text('$label: ',
            style: TextStyle(fontSize: 13.5 * uiScale, color: tk.onMuted)),
        Text(value,
            style: TextStyle(
                fontSize: 13.5 * uiScale,
                fontWeight: FontWeight.w600,
                color: tk.onBg)),
      ],
    );
  }
}

class _ToggleInfo extends StatelessWidget {
  const _ToggleInfo({required this.label, required this.value});

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final color = value ? tk.success : tk.onFaint;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(value ? Icons.check_circle_rounded : Icons.cancel_outlined,
              size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(fontSize: 13.5 * uiScale, color: tk.onBg)),
        ],
      ),
    );
  }
}

class _RatingsCard extends StatelessWidget {
  const _RatingsCard({required this.entry});

  final VapeEntry entry;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: Column(
        children: [
          _RatingRow(label: 'Сладость', value: entry.sweetness),
          _RatingRow(label: 'Холодок', value: entry.coolness),
          _RatingRow(label: 'Насыщенность', value: entry.richness),
          _RatingRow(label: 'Общая оценка', value: entry.rating, bold: true),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.label, required this.value, this.bold = false});

  final String label;
  final int? value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final v = value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.5 * uiScale,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    color: tk.onBg)),
          ),
          Text(
            v == null ? '—' : '${(v / 10).toStringAsFixed(1)} /10',
            style: TextStyle(
                fontSize: 14 * uiScale,
                fontWeight: FontWeight.w800,
                color: v == null ? tk.onFaint : tk.scoreColor(v)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12.5 * uiScale,
                fontWeight: FontWeight.w700,
                color: tk.onMuted)),
        const SizedBox(height: 6),
        Text(body,
            style: TextStyle(
                fontSize: 14 * uiScale, color: tk.onBg, height: 1.5)),
      ],
    );
  }
}

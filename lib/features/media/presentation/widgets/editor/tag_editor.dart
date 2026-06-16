import 'package:flutter/material.dart';

import '../../../../../core/catalog/tag.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../domain/media_genres.dart';
import 'editor_primitives.dart';

/// Сколько популярных тегов показывать чипами (сверх выбранных).
const int _maxPopular = 10;

/// Максимум строк-подсказок при вводе.
const int _maxSuggestions = 6;

/// Редактор тегов карточки. Чипы — только популярные у пользователя теги
/// (по числу карточек) + уже выбранные. Ввод нового тега даёт подсказки из
/// существующих тегов (переиспользование, без дублей) и словаря жанров.
class TagEditor extends StatefulWidget {
  const TagEditor({
    super.key,
    required this.allTags,
    required this.selectedIds,
    required this.onToggle,
    required this.onCreate,
  });

  /// Все теги справочника с числом живых карточек (для популярности).
  final List<TagWithCount> allTags;
  final Set<String> selectedIds;

  /// Переключить существующий тег (по id).
  final ValueChanged<String> onToggle;

  /// Создать/выбрать тег по имени (`TagRepository.ensure` дедуплицирует).
  final ValueChanged<String> onCreate;

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() => _query = '');
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onCreate(name);
    _clear();
  }

  /// Чипы: сначала выбранные, затем самые используемые (count > 0), без дублей.
  List<Tag> _chipTags() {
    final selected = widget.allTags
        .where((t) => widget.selectedIds.contains(t.tag.id))
        .map((t) => t.tag)
        .toList();
    final popular = ([...widget.allTags]
          ..sort((a, b) => b.count.compareTo(a.count)))
        .where((t) => t.count > 0 && !widget.selectedIds.contains(t.tag.id))
        .take(_maxPopular)
        .map((t) => t.tag)
        .toList();
    return [...selected, ...popular];
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final chips = _chipTags();
    final q = _query.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chips.isNotEmpty) ...[
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final tag in chips)
                EditorChip(
                  label: tag.name,
                  selected: widget.selectedIds.contains(tag.id),
                  accent: tk.secondary,
                  onTap: () => widget.onToggle(tag.id),
                ),
            ],
          ),
          const SizedBox(height: 9),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onTapOutside: dismissKeyboardOnTapOutside,
                textInputAction: TextInputAction.done,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (_) => _submit(),
                style: TextStyle(fontSize: 13.5 * uiScale, color: tk.onBg),
                decoration: editorFieldDecoration(context, hint: 'Добавить тег'),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: tk.tint(tk.secondary, 0.16),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: InkWell(
                onTap: _submit,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.add_rounded, color: tk.secondary, size: 20),
                ),
              ),
            ),
          ],
        ),
        if (q.isNotEmpty) _suggestions(context, q),
      ],
    );
  }

  Widget _suggestions(BuildContext context, String q) {
    final tk = context.tokens;
    final ql = q.toLowerCase();

    final existing = widget.allTags
        .where((t) =>
            !widget.selectedIds.contains(t.tag.id) &&
            t.tag.name.toLowerCase().contains(ql))
        .map((t) => t.tag)
        .toList();
    final existingNamesLower = {
      for (final t in widget.allTags) t.tag.name.toLowerCase()
    };
    final genres = kMediaGenres
        .where((g) =>
            g.toLowerCase().contains(ql) &&
            !existingNamesLower.contains(g.toLowerCase()))
        .toList();
    final exact = existingNamesLower.contains(ql) ||
        genres.any((g) => g.toLowerCase() == ql);

    final rows = <Widget>[];
    for (final t in existing) {
      if (rows.length >= _maxSuggestions) break;
      rows.add(_SuggestionRow(
        icon: Icons.sell_outlined,
        label: t.name,
        hint: 'выбрать',
        onTap: () {
          widget.onToggle(t.id);
          _clear();
        },
      ));
    }
    for (final g in genres) {
      if (rows.length >= _maxSuggestions) break;
      rows.add(_SuggestionRow(
        icon: Icons.add_circle_outline_rounded,
        label: g,
        hint: 'жанр',
        onTap: () {
          widget.onCreate(g);
          _clear();
        },
      ));
    }
    if (!exact) {
      rows.add(_SuggestionRow(
        icon: Icons.add_rounded,
        label: 'Создать «$q»',
        onTap: () {
          widget.onCreate(q);
          _clear();
        },
      ));
    }
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hint,
  });

  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 17, color: tk.onMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13 * uiScale, color: tk.onBg),
              ),
            ),
            if (hint != null)
              Text(
                hint!,
                style: TextStyle(fontSize: 11 * uiScale, color: tk.onFaint),
              ),
          ],
        ),
      ),
    );
  }
}

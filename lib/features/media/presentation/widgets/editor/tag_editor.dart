import 'package:flutter/material.dart';

import '../../../../../core/catalog/tag.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import 'editor_primitives.dart';

/// Редактор тегов карточки: выбор из существующих (чипы) + добавление нового.
/// Новый тег создаётся через справочник ([onCreate] → `TagRepository.ensure`).
class TagEditor extends StatefulWidget {
  const TagEditor({
    super.key,
    required this.allTags,
    required this.selectedIds,
    required this.onToggle,
    required this.onCreate,
  });

  final List<Tag> allTags;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onCreate;

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onCreate(name);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.allTags.isNotEmpty)
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final tag in widget.allTags)
                EditorChip(
                  label: tag.name,
                  selected: widget.selectedIds.contains(tag.id),
                  accent: tk.secondary,
                  onTap: () => widget.onToggle(tag.id),
                ),
            ],
          ),
        if (widget.allTags.isNotEmpty) const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                style: TextStyle(fontSize: 13.5 * uiScale, color: tk.onBg),
                decoration: editorFieldDecoration(context, hint: 'Новый тег'),
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
      ],
    );
  }
}

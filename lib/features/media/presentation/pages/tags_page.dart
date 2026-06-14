import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/catalog/tag.dart';
import '../../../../core/catalog/tag_repository.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/confirm_sheet.dart';
import '../../../../core/ui/hex_color.dart';
import '../cubit/tag_manager_cubit.dart';

/// Палитра цветов тегов (берём акценты тем — выглядят уместно в любой теме).
const _tagPalette = <String>[
  '#BE5D49', '#D06A86', '#5E8C4F', '#5560D6', '#D07A3C',
  '#5E7A6F', '#8A6E9E', '#3F9FA6', '#978B80',
];

/// Экран 05 — управление тегами: переименование, цвет, слияние, удаление.
class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const TagsPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TagManagerCubit(getIt<TagRepository>()),
      child: const _TagsView(),
    );
  }
}

class _TagsView extends StatelessWidget {
  const _TagsView();

  Future<void> _newTag(BuildContext context) async {
    final cubit = context.read<TagManagerCubit>();
    final name = await _showNewTagDialog(context);
    if (name != null) await cubit.create(name);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TagManagerCubit, TagManagerState>(
          builder: (context, state) {
            return Column(
              children: [
                _TopBar(count: state.tags.length),
                Expanded(
                  child: state.loading
                      ? const SizedBox.shrink()
                      : state.isEmpty
                          ? const _EmptyTags()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: state.tags.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) => _TagRow(
                                key: ValueKey(state.tags[i].tag.id),
                                entry: state.tags[i],
                                others: state.tags,
                              ),
                            ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, 12 + MediaQuery.paddingOf(context).bottom),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => _newTag(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Новый тег'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      backgroundColor: tk.bg,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tk.onBg),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text('Теги', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('$count', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TagRow extends StatefulWidget {
  const _TagRow({super.key, required this.entry, required this.others});

  final TagWithCount entry;
  final List<TagWithCount> others;

  @override
  State<_TagRow> createState() => _TagRowState();
}

class _TagRowState extends State<_TagRow> {
  final _controller = TextEditingController();
  bool _editing = false;

  Tag get _tag => widget.entry.tag;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRename() {
    _controller.text = _tag.name;
    setState(() => _editing = true);
  }

  void _commitRename() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && name != _tag.name) {
      context.read<TagManagerCubit>().rename(_tag.id, name);
    }
    setState(() => _editing = false);
  }

  Future<void> _pickColor() async {
    final cubit = context.read<TagManagerCubit>();
    final result = await _showColorSheet(context, _tag.color);
    if (result != null) await cubit.recolor(_tag.id, result.color);
  }

  Future<void> _mergeInto() async {
    final cubit = context.read<TagManagerCubit>();
    final others =
        widget.others.where((t) => t.tag.id != _tag.id).map((t) => t.tag).toList();
    if (others.isEmpty) return;
    final target = await _showTagPicker(context, others);
    if (target == null || !mounted) return;
    final ok = await showConfirmDeleteSheet(
      context,
      title: 'Слить теги?',
      message: 'Карточки тега «${_tag.name}» получат тег «${target.name}», '
          'а «${_tag.name}» удалится.',
      confirmLabel: 'Слить',
    );
    if (ok) await cubit.merge(_tag.id, target.id);
  }

  Future<void> _delete() async {
    final cubit = context.read<TagManagerCubit>();
    final ok = await showConfirmDeleteSheet(
      context,
      title: 'Удалить тег?',
      message: 'Тег «${_tag.name}» снимется со всех карточек. '
          'Сами карточки останутся.',
    );
    if (ok) await cubit.delete(_tag.id);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final dotColor = parseHexColor(_tag.color) ?? tk.secondary;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: _editing ? tk.primary : tk.outlineSoft,
          width: _editing ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickColor,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 11),
          if (_editing)
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                onSubmitted: (_) => _commitRename(),
                style: TextStyle(
                    fontSize: 14 * uiScale,
                    fontWeight: FontWeight.w600,
                    color: tk.onBg),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                _tag.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          if (_editing)
            TextButton(onPressed: _commitRename, child: const Text('Готово'))
          else ...[
            Text('${widget.entry.count}',
                style: Theme.of(context).textTheme.labelMedium),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz_rounded, color: tk.onMuted),
              onSelected: (v) {
                switch (v) {
                  case 'rename':
                    _startRename();
                  case 'color':
                    _pickColor();
                  case 'merge':
                    _mergeInto();
                  case 'delete':
                    _delete();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'rename', child: Text('Переименовать')),
                const PopupMenuItem(value: 'color', child: Text('Цвет')),
                if (widget.others.length > 1)
                  const PopupMenuItem(value: 'merge', child: Text('Слить с…')),
                const PopupMenuItem(value: 'delete', child: Text('Удалить')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyTags extends StatelessWidget {
  const _EmptyTags();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.label_outline_rounded, size: 48, color: tk.onFaint),
            const SizedBox(height: 14),
            Text('Тегов пока нет', style: text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Добавьте тег — он станет доступен в карточках',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── листы выбора ────────────────────────────────

/// Возвращает выбранный цвет (`color` = hex или null для «без цвета»).
Future<({String? color})?> _showColorSheet(
    BuildContext context, String? current) {
  final tk = context.tokens;
  return showModalBottomSheet<({String? color})>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Цвет тега', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _ColorDot(
                color: tk.surface3,
                selected: current == null,
                isNone: true,
                onTap: () => Navigator.pop(context, (color: null)),
              ),
              for (final hex in _tagPalette)
                _ColorDot(
                  color: parseHexColor(hex)!,
                  selected: current == hex,
                  isNone: false,
                  onTap: () => Navigator.pop(context, (color: hex)),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.isNone,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final bool isNone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: tk.onBg, width: 2) : null,
        ),
        child: isNone
            ? Icon(Icons.block_rounded, size: 18, color: tk.onFaint)
            : selected
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : null,
      ),
    );
  }
}

/// Лист выбора целевого тега для слияния. Возвращает выбранный [Tag].
Future<Tag?> _showTagPicker(BuildContext context, List<Tag> tags) {
  final tk = context.tokens;
  return showModalBottomSheet<Tag>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: tk.surface2,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      padding: EdgeInsets.only(
          top: 16, bottom: MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Text('Слить с тегом', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final tag in tags)
                  ListTile(
                    leading: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: parseHexColor(tag.color) ?? tk.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(tag.name),
                    onTap: () => Navigator.pop(context, tag),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<String?> _showNewTagDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Новый тег'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Название'),
        onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: const Text('Создать'),
        ),
      ],
    ),
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/catalog/catalog_date.dart';
import '../../../../core/catalog/date_precision.dart';
import '../../../../core/images/image_storage.dart';
import '../../../../core/images/media_paths.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/catalog_date_format.dart';
import '../../../media/presentation/widgets/editor/editor_primitives.dart';
import '../../../media/presentation/widgets/editor/rating_input.dart';
import '../../domain/flavor_category.dart';
import '../../domain/nicotine_strengths.dart';
import '../../domain/nicotine_type.dart';
import '../../domain/vape_repository.dart';
import '../cubit/vape_editor_cubit.dart';

const List<String> _months = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', //
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

/// Открывает редактор жидкости как модальный боттом-шит (ADR-20/22).
Future<void> openVapeEditor(BuildContext context, {String? entryId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => VapeEditorSheet(entryId: entryId),
  );
}

class VapeEditorSheet extends StatelessWidget {
  const VapeEditorSheet({super.key, this.entryId});

  final String? entryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VapeEditorCubit(
        getIt<VapeRepository>(),
        getIt<ImageStorage>(),
        entryId: entryId,
      ),
      child: BlocBuilder<VapeEditorCubit, VapeEditorState>(
        buildWhen: (a, b) => a.loading != b.loading,
        builder: (context, state) =>
            state.loading ? const _LoadingSheet() : const _EditorForm(),
      ),
    );
  }
}

BoxDecoration _sheetDecoration(BuildContext context) => BoxDecoration(
      color: context.tokens.surface2,
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    );

class _LoadingSheet extends StatelessWidget {
  const _LoadingSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: _sheetDecoration(context),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DragHandle(),
            SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: context.tokens.surface3,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

class _EditorForm extends StatefulWidget {
  const _EditorForm();

  @override
  State<_EditorForm> createState() => _EditorFormState();
}

class _EditorFormState extends State<_EditorForm> with WidgetsBindingObserver {
  late final TextEditingController _brand;
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _note;

  final FocusNode _noteFocus = FocusNode();
  final GlobalKey _noteKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final s = context.read<VapeEditorCubit>().state;
    _brand = TextEditingController(text: s.brand);
    _title = TextEditingController(text: s.title);
    _desc = TextEditingController(text: s.flavorDescription ?? '');
    _note = TextEditingController(text: s.note ?? '');
    WidgetsBinding.instance.addObserver(this);
    _noteFocus.addListener(_onNoteFocusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _brand.dispose();
    _title.dispose();
    _desc.dispose();
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _onNoteFocusChanged() {
    if (!mounted) return;
    setState(() {});
    _ensureNoteVisible();
  }

  @override
  void didChangeMetrics() {
    if (_noteFocus.hasFocus) _ensureNoteVisible();
  }

  void _ensureNoteVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _noteKey.currentContext;
      if (!mounted || ctx == null || !_noteFocus.hasFocus) return;
      Scrollable.ensureVisible(ctx, duration: Duration.zero, alignment: 0.5);
    });
  }

  Future<bool> _confirmDiscard() async {
    final s = context.read<VapeEditorCubit>().state;
    final hasInput = s.brand.trim().isNotEmpty || s.title.trim().isNotEmpty;
    if (!(s.mode == EditorMode.create && hasInput)) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отменить создание?'),
        content: const Text('Введённые данные не сохранятся.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Продолжить')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Отменить')),
        ],
      ),
    );
    return discard == true;
  }

  Future<void> _pickCover(BuildContext context) async {
    final cubit = context.read<VapeEditorCubit>();
    final source = await _chooseImageSource(context);
    if (source == null) return;
    XFile? file;
    try {
      file = await ImagePicker()
          .pickImage(source: source, maxWidth: 2048, maxHeight: 2048);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              content: Text('Не удалось открыть камеру или галерею')));
      }
      return;
    }
    if (file != null) await cubit.attachCover(file.path);
  }

  Future<ImageSource?> _chooseImageSource(BuildContext context) {
    final tk = context.tokens;
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: tk.surface2,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        padding:
            EdgeInsets.only(top: 8, bottom: MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: tk.onMuted),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: tk.onMuted),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    return BlocConsumer<VapeEditorCubit, VapeEditorState>(
      listenWhen: (a, b) =>
          a.justSaved != b.justSaved || a.errorMessage != b.errorMessage,
      listener: (context, state) {
        if (state.justSaved) {
          Navigator.of(context).pop();
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<VapeEditorCubit>();
        final guardUnsaved = state.mode == EditorMode.create &&
            (state.brand.trim().isNotEmpty || state.title.trim().isNotEmpty) &&
            !state.justSaved &&
            !state.saving;
        return PopScope(
          canPop: !guardUnsaved,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmDiscard() && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: Container(
              constraints: BoxConstraints(maxHeight: maxH),
              decoration: _sheetDecoration(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _DragHandle(),
                  _SheetHeader(
                    title: state.mode == EditorMode.create
                        ? 'Добавить жидкость'
                        : 'Редактирование',
                    canSave: state.canSave,
                    saving: state.saving,
                    onSave: cubit.save,
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                          16, 4, 16, _noteFocus.hasFocus ? 96 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _fields(context, state, cubit),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _fields(
      BuildContext context, VapeEditorState s, VapeEditorCubit cubit) {
    final tk = context.tokens;
    final strengths =
        s.nicotineType == null ? const <String>[] : nicotineStrengthsFor(s.nicotineType!);
    return [
      const EditorLabel('Бренд', required: true),
      TextField(
        controller: _brand,
        onChanged: cubit.setBrand,
        onTapOutside: dismissKeyboardOnTapOutside,
        maxLength: 30,
        buildCounter: coloredCharCounter,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(fontSize: 14.5 * uiScale, fontWeight: FontWeight.w600, color: tk.onBg),
        decoration: editorFieldDecoration(context, hint: 'Производитель'),
      ),
      const SizedBox(height: 10),
      const EditorLabel('Название вкуса', required: true),
      TextField(
        controller: _title,
        onChanged: cubit.setTitle,
        onTapOutside: dismissKeyboardOnTapOutside,
        maxLength: 50,
        buildCounter: coloredCharCounter,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(fontSize: 14.5 * uiScale, fontWeight: FontWeight.w600, color: tk.onBg),
        decoration: editorFieldDecoration(context, hint: 'Например, Манго-лёд'),
      ),
      const SizedBox(height: 14),
      const EditorLabel('Фото упаковки'),
      Align(
        alignment: Alignment.centerLeft,
        child: _CoverThumb(
          coverImageId: s.coverImageId,
          processing: s.processingImage,
          onPick: () => _pickCover(context),
          onRemove: cubit.removeCover,
        ),
      ),
      const SizedBox(height: 14),
      const EditorLabel('Тип никотина', required: true),
      EditorSegments<NicotineType>(
        value: s.nicotineType,
        onChanged: cubit.setNicotineType,
        options: const [
          (NicotineType.salt, 'Солевой'),
          (NicotineType.alkaline, 'Щелочной'),
          (NicotineType.hybrid, 'Гибрид'),
        ],
      ),
      if (s.nicotineType != null) ...[
        const SizedBox(height: 14),
        const EditorLabel('Крепость, мг/мл', required: true),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final v in strengths)
              EditorChip(
                label: v,
                selected: s.nicotineStrength == v,
                onTap: () => cubit.setNicotineStrength(v),
              ),
          ],
        ),
      ],
      const SizedBox(height: 14),
      const EditorLabel('Дата добавления'),
      _AddedDateField(value: s.addedAt, onChanged: cubit.setAddedAt),
      const SizedBox(height: 16),
      _ExpandableSection(
        title: 'Дополнительные параметры',
        subtitle: 'Вкус, оценки, комментарий…',
        child: _extra(context, s, cubit),
      ),
    ];
  }

  Widget _extra(BuildContext context, VapeEditorState s, VapeEditorCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditorLabel('Основная категория вкуса'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final c in FlavorCategory.values)
              EditorChip(
                label: c.label,
                accent: context.tokens.secondary,
                selected: s.flavorCategory == c,
                onTap: () =>
                    cubit.setFlavorCategory(s.flavorCategory == c ? null : c),
              ),
          ],
        ),
        const SizedBox(height: 14),
        const EditorLabel('Описание вкуса'),
        TextField(
          controller: _desc,
          onChanged: cubit.setFlavorDescription,
          onTapOutside: dismissKeyboardOnTapOutside,
          minLines: 2,
          maxLines: 4,
          maxLength: 150,
          buildCounter: coloredCharCounter,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
              fontSize: 13.5 * uiScale, color: context.tokens.onBg, height: 1.4),
          decoration: editorFieldDecoration(context,
              hint: 'Как ощущается вкус…', italicHint: true),
        ),
        const SizedBox(height: 14),
        RatingInput(
            label: 'Уровень сладости',
            value: s.sweetness,
            onChanged: cubit.setSweetness),
        const SizedBox(height: 10),
        RatingInput(
            label: 'Уровень холодка',
            value: s.coolness,
            onChanged: cubit.setCoolness),
        const SizedBox(height: 10),
        RatingInput(
            label: 'Насыщенность вкуса',
            value: s.richness,
            onChanged: cubit.setRichness),
        const SizedBox(height: 10),
        RatingInput(
            label: 'Общая оценка вкуса',
            value: s.rating,
            onChanged: cubit.setRating),
        const SizedBox(height: 6),
        _ToggleRow(
            label: 'Можно покупать снова',
            value: s.canRebuy,
            onChanged: cubit.setCanRebuy),
        _ToggleRow(
            label: 'Мылится вкус',
            value: s.flavorFades,
            onChanged: cubit.setFlavorFades),
        const SizedBox(height: 12),
        const EditorLabel('Комментарий'),
        TextField(
          key: _noteKey,
          controller: _note,
          focusNode: _noteFocus,
          onChanged: cubit.setNote,
          onTapOutside: dismissKeyboardOnTapOutside,
          minLines: 3,
          maxLines: 6,
          maxLength: 256,
          buildCounter: coloredCharCounter,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
              fontSize: 13.5 * uiScale,
              fontStyle: FontStyle.italic,
              color: context.tokens.onBg,
              height: 1.5),
          decoration: editorFieldDecoration(context,
              hint: 'Заметки, впечатления…', italicHint: true),
        ),
      ],
    );
  }
}

// ─────────────────────────── шапка ───────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.canSave,
    required this.saving,
    required this.onSave,
  });

  final String title;
  final bool canSave;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 15.5 * uiScale,
                  fontWeight: FontWeight.w700,
                  color: tk.onBg),
            ),
          ),
          Semantics(
            button: true,
            enabled: canSave,
            label: 'Сохранить',
            excludeSemantics: true,
            onTap: canSave ? onSave : null,
            child: Material(
              color: canSave ? tk.primary : tk.surface3,
              shape: const CircleBorder(),
              child: InkWell(
                key: const Key('vape-editor-save'),
                onTap: canSave ? onSave : null,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: saving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: tk.onPrimary))
                      : Icon(Icons.check_rounded,
                          size: 20,
                          color: canSave ? tk.onPrimary : tk.onFaint),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── дата добавления (пикер дня) ──────────────────────────

class _AddedDateField extends StatelessWidget {
  const _AddedDateField({required this.value, required this.onChanged});

  final CatalogDate? value;
  final ValueChanged<CatalogDate?> onChanged;

  String _label() {
    final v = value;
    if (v == null) return 'Выбрать дату';
    final d = v.value;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  Future<void> _pick(BuildContext context) async {
    final tk = context.tokens;
    final now = DateTime.now();
    var picked = value?.value.toLocal() ?? now;
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: tk.surface2,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        padding:
            EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 2),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: tk.surface3,
                  borderRadius: BorderRadius.circular(AppRadii.pill)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 64),
                  Text('Дата добавления',
                      style: TextStyle(
                          fontSize: 14 * uiScale,
                          fontWeight: FontWeight.w700,
                          color: tk.onBg)),
                  TextButton(
                    onPressed: () => Navigator.pop(context, picked),
                    child: Text('Готово',
                        style: TextStyle(
                            color: tk.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 190,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle:
                        TextStyle(fontSize: 18 * uiScale, color: tk.onBg),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: picked,
                  maximumDate: DateTime(now.year + 1, now.month, now.day),
                  minimumYear: 2000,
                  onDateTimeChanged: (d) => picked = d,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      onChanged(normalizeCatalogDate(result, DatePrecision.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: tk.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: tk.outlineSoft),
          ),
          child: Row(
            children: [
              Icon(Icons.event_rounded, size: 18, color: tk.onMuted),
              const SizedBox(width: 10),
              Text(
                _label(),
                style: TextStyle(
                    fontSize: 13.5 * uiScale,
                    fontWeight: FontWeight.w600,
                    color: value == null ? tk.onFaint : tk.onBg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── тугл ────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 13.5 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: tk.onBg),
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────── раскрывающийся блок (дубль из медиа) ─────────────────

class _ExpandableSection extends StatefulWidget {
  const _ExpandableSection({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tk.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tk.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: TextStyle(
                                fontSize: 13.5 * uiScale,
                                fontWeight: FontWeight.w700,
                                color: tk.onBg)),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(widget.subtitle!,
                              style: TextStyle(
                                  fontSize: 11 * uiScale, color: tk.onMuted)),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppDurations.base,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: tk.onMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: AppDurations.base,
            curve: const Cubic(0.2, 0, 0, 1),
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── превью фото (дубль из медиа) ─────────────────────────

class _CoverThumb extends StatelessWidget {
  const _CoverThumb({
    required this.coverImageId,
    required this.processing,
    required this.onPick,
    required this.onRemove,
  });

  final String? coverImageId;
  final bool processing;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final has = coverImageId != null;
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              button: true,
              label: has ? 'Заменить фото' : 'Добавить фото',
              child: GestureDetector(
                onTap: processing ? null : onPick,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tk.surface,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: tk.outlineSoft),
                  ),
                  child: processing
                      ? const Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : has
                          ? Image.file(
                              getIt<MediaPaths>().absFull(coverImageId!),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (_, _, _) => Icon(
                                  Icons.broken_image_outlined,
                                  color: tk.onFaint),
                            )
                          : Center(
                              child: Icon(Icons.add_photo_alternate_outlined,
                                  size: 26, color: tk.onFaint)),
                ),
              ),
            ),
          ),
          if (has && !processing)
            Positioned(
              top: 4,
              right: 4,
              child: Semantics(
                button: true,
                label: 'Убрать фото',
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/catalog/tag_repository.dart';
import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/images/image_storage.dart';
import '../../../../core/images/media_paths.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/ui/status_visuals.dart';
import '../../domain/media_format.dart';
import '../../domain/media_repository.dart';
import '../../domain/media_type.dart';
import '../cubit/media_editor_cubit.dart';
import '../widgets/editor/country_field.dart';
import '../widgets/editor/editor_primitives.dart';
import '../widgets/editor/rating_input.dart';
import '../widgets/editor/tag_editor.dart';
import '../widgets/editor/watch_dates_section.dart';
import '../widgets/editor/year_field.dart';

/// Открывает редактор карточки (экран 03) как модальный боттом-шит.
/// `entryId == null` — создание, иначе редактирование существующей карточки.
///
/// ADR-20: модалки — через `showModalBottomSheet` + `Navigator.pop` (не
/// go_router-роут). Крестика в шапке нет — закрытие свайпом вниз / тапом по
/// затемнению (как в дизайн-референсе). Форма раскрывается прогрессивно:
/// Формат → Тип → Название → «Дополнительные параметры».
Future<void> openMediaEditor(BuildContext context, {String? entryId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MediaEditorSheet(entryId: entryId),
  );
}

/// Содержимое модального шита: создаёт [MediaEditorCubit] и строит форму, когда
/// загрузка завершена.
class MediaEditorSheet extends StatelessWidget {
  const MediaEditorSheet({super.key, this.entryId});

  final String? entryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MediaEditorCubit(
        getIt<MediaRepository>(),
        getIt<TagRepository>(),
        getIt<ImageStorage>(),
        entryId: entryId,
      ),
      child: BlocBuilder<MediaEditorCubit, MediaEditorState>(
        buildWhen: (a, b) => a.loading != b.loading,
        builder: (context, state) =>
            state.loading ? const _LoadingSheet() : const _EditorForm(),
      ),
    );
  }
}

/// Декорация контейнера шита: surface2 + скруглённый верх.
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
            SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Грабер» сверху шита — визуальная подсказка, что лист тянется/закрывается.
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
  late final TextEditingController _title;
  late final TextEditingController _original;
  late final TextEditingController _note;

  /// Фокус и ключ поля «Заметка» — оно последнее и многострочное, со счётчиком
  /// символов, поэтому при наборе пряталось под клавиатурой. По фокусу
  /// поднимаем его целиком в зону видимости (см. [_ensureNoteVisible]).
  final FocusNode _noteFocus = FocusNode();
  final GlobalKey _noteKey = GlobalKey();

  /// Раскрыт ли блок «Дополнительные параметры». В режиме редактирования —
  /// сразу раскрыт (там обычно уже есть данные).
  late bool _extraExpanded;

  @override
  void initState() {
    super.initState();
    final s = context.read<MediaEditorCubit>().state;
    _title = TextEditingController(text: s.title);
    _original = TextEditingController(text: s.originalTitle ?? '');
    _note = TextEditingController(text: s.note ?? '');
    _extraExpanded = s.mode == EditorMode.edit;
    WidgetsBinding.instance.addObserver(this);
    _noteFocus.addListener(_onNoteFocusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _title.dispose();
    _original.dispose();
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  /// Фокус «Заметки» сменился: запас прокрутки снизу зависит от него (setState),
  /// и поле сразу подскролливается (клавиатура могла уже быть открыта — переход
  /// с другого поля).
  void _onNoteFocusChanged() {
    if (!mounted) return;
    setState(() {}); // переключает нижний паддинг скролла (см. build)
    _ensureNoteVisible();
  }

  @override
  void didChangeMetrics() {
    // Клавиатура выезжает анимированно → viewInsets меняется по кадрам; пока
    // «Заметка» в фокусе, докручиваем её над клавиатурой на каждом шаге
    // (без магической задержки на окончание анимации).
    if (_noteFocus.hasFocus) _ensureNoteVisible();
  }

  /// Скроллит поле «Заметка» (вместе со счётчиком) в видимую зону над
  /// клавиатурой. Duration.zero — мгновенно на каждом шаге анимации инсетов:
  /// визуально плавно, без наложения анимаций скролла.
  void _ensureNoteVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _noteKey.currentContext;
      if (!mounted || ctx == null || !_noteFocus.hasFocus) return;
      Scrollable.ensureVisible(ctx, duration: Duration.zero, alignment: 0.5);
    });
  }

  /// Подтверждение отмены: диалог только при создании с непустым вводом.
  /// Возвращает true, если можно уходить (терять нечего или подтвердили).
  /// Общий путь для системного «назад» и свайпа-закрытия (PopScope).
  Future<bool> _confirmDiscard() async {
    final s = context.read<MediaEditorCubit>().state;
    if (!(s.mode == EditorMode.create && s.title.trim().isNotEmpty)) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отменить создание?'),
        content: const Text('Введённые данные не сохранятся.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Продолжить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );
    return discard == true;
  }

  Future<void> _pickCover(BuildContext context) async {
    final cubit = context.read<MediaEditorCubit>();
    final source = await _chooseImageSource(context);
    if (source == null) return;
    XFile? file;
    try {
      file = await ImagePicker()
          .pickImage(source: source, maxWidth: 2048, maxHeight: 2048);
    } catch (_) {
      // Пикер упал (нет доступа к камере/галерее) — раньше молчали; сообщаем.
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
        padding: EdgeInsets.only(
            top: 8, bottom: MediaQuery.paddingOf(context).bottom),
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
    return BlocConsumer<MediaEditorCubit, MediaEditorState>(
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
        final cubit = context.read<MediaEditorCubit>();
        // Свайп-закрытие/системный «назад» при несохранённом вводе спрашивает
        // подтверждение. canPop гейтит ТОЛЬКО непрограммный pop; программный
        // Navigator.pop (justSaved) безусловен.
        final guardUnsaved = state.mode == EditorMode.create &&
            state.title.trim().isNotEmpty &&
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
                        ? 'Добавить просмотр'
                        : 'Редактирование',
                    canSave: state.canSave,
                    saving: state.saving,
                    onSave: cubit.save,
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      // При фокусе на «Заметке» — запас снизу, чтобы поле со
                      // счётчиком встало над клавиатурой с отступом
                      // (см. _ensureNoteVisible).
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

  // ─────────────────────────── прогрессивная форма ──────────────────────────

  List<Widget> _fields(
      BuildContext context, MediaEditorState state, MediaEditorCubit cubit) {
    return [
      const EditorLabel('Формат'),
      EditorSegments<MediaFormat>(
        value: state.format,
        onChanged: cubit.setFormat,
        options: const [
          (MediaFormat.single, 'Одиночный'),
          (MediaFormat.episodic, 'Серийный'),
        ],
      ),
      // Тип — только когда выбран формат (подписи видов зависят от формата).
      if (state.format != null) ...[
        const SizedBox(height: 14),
        const EditorLabel('Тип'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final type in MediaType.values)
              EditorChip(
                label: type.labelFor(state.format!),
                selected: state.mediaType == type,
                onTap: () => cubit.setMediaType(type),
              ),
          ],
        ),
      ],
      // Название и всё остальное — только когда выбран тип.
      if (state.mediaType != null) ...[
        const SizedBox(height: 14),
        const EditorLabel('Название', required: true),
        TextField(
          controller: _title,
          onChanged: cubit.setTitle,
          onTapOutside: dismissKeyboardOnTapOutside,
          maxLength: 100,
          buildCounter: coloredCharCounter,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            fontSize: 14.5 * uiScale,
            fontWeight: FontWeight.w600,
            color: context.tokens.onBg,
          ),
          decoration: editorFieldDecoration(context, hint: 'Название'),
        ),
        const SizedBox(height: 16),
        _ExpandableSection(
          title: 'Дополнительные параметры',
          subtitle: 'Статус, оценка, обложка, теги, даты, заметка…',
          expanded: _extraExpanded,
          onToggle: () => setState(() => _extraExpanded = !_extraExpanded),
          child: _extra(context, state, cubit),
        ),
      ],
    ];
  }

  Widget _extra(
      BuildContext context, MediaEditorState state, MediaEditorCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditorLabel('Статус'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (i, s) in WatchStatus.values.indexed) ...[
                if (i > 0) const SizedBox(width: 7),
                EditorChip(
                  label: StatusVisual.label(s),
                  icon: StatusVisual.icon(s),
                  accent: context.tokens.statusColor(s),
                  selected: state.status == s,
                  onTap: () => cubit.setStatus(s),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _CoverInfoRow(
          coverImageId: state.coverImageId,
          processing: state.processingImage,
          onPickCover: () => _pickCover(context),
          onRemoveCover: cubit.removeCover,
          originalController: _original,
          onOriginalChanged: cubit.setOriginalTitle,
          year: state.year,
          onYearChanged: cubit.setYear,
          country: state.country,
          onCountryChanged: cubit.setCountry,
        ),
        const SizedBox(height: 14),
        RatingInput(value: state.rating, onChanged: cubit.setRating),
        const SizedBox(height: 14),
        const EditorLabel('Теги'),
        TagEditor(
          allTags: state.allTags,
          selectedIds: state.selectedTagIds,
          onToggle: cubit.toggleTag,
          onCreate: cubit.addTag,
        ),
        _conditional(
          visible: state.isEpisodic,
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: _ProgressBlock(state: state, cubit: cubit),
          ),
        ),
        _conditional(
          visible: state.showReason,
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: _ReasonBlock(state: state, cubit: cubit),
          ),
        ),
        const SizedBox(height: 18),
        WatchDatesSection(
          startedAt: state.startedAt,
          onStarted: (d) => cubit.setDate(EditorDateSlot.started, d),
          lastActivityAt: state.lastActivityAt,
          onLastActivity: (d) => cubit.setDate(EditorDateSlot.lastActivity, d),
          finishedAt: state.finishedAt,
          onFinished: (d) => cubit.setDate(EditorDateSlot.finished, d),
          rewatchCount: state.rewatchCount,
          onRewatchChanged: cubit.setRewatchCount,
        ),
        const SizedBox(height: 18),
        const EditorLabel('Заметка'),
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
            height: 1.5,
          ),
          decoration: editorFieldDecoration(
            context,
            hint: 'Ваш отзыв, мысли, на чём остановились…',
            italicHint: true,
          ),
        ),
      ],
    );
  }

  /// Анимированное раскрытие/скрытие условного блока (серии, причина).
  Widget _conditional({required bool visible, required Widget child}) {
    return AnimatedSize(
      duration: AppDurations.base,
      curve: const Cubic(0.2, 0, 0, 1),
      alignment: Alignment.topCenter,
      child: visible ? child : const SizedBox(width: double.infinity),
    );
  }
}

// ─────────────────────────── шапка шита ──────────────────────────────────

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
                color: tk.onBg,
              ),
            ),
          ),
          _SaveIconButton(enabled: canSave, saving: saving, onTap: onSave),
        ],
      ),
    );
  }
}

class _SaveIconButton extends StatelessWidget {
  const _SaveIconButton({
    required this.enabled,
    required this.saving,
    required this.onTap,
  });

  final bool enabled;
  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Сохранить',
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Material(
        color: enabled ? tk.primary : tk.surface3,
        shape: const CircleBorder(),
        child: InkWell(
          key: const Key('editor-save'),
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tk.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: enabled ? tk.onPrimary : tk.onFaint,
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── раскрывающийся блок ─────────────────────────────

/// Сворачиваемая секция «Дополнительные параметры»: кликабельная шапка с
/// поворачивающимся шевроном + анимированное раскрытие содержимого.
class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

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
              onToggle();
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
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.5 * uiScale,
                            fontWeight: FontWeight.w700,
                            color: tk.onBg,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 11 * uiScale,
                              color: tk.onMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
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
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── обложка + основное (одной строкой) ───────────────────

/// Слева — обложка, справа в две строки: оригинальное название и (год+страна),
/// выровненные по высоте обложки. Текст-подсказка у обложки убрана.
class _CoverInfoRow extends StatelessWidget {
  const _CoverInfoRow({
    required this.coverImageId,
    required this.processing,
    required this.onPickCover,
    required this.onRemoveCover,
    required this.originalController,
    required this.onOriginalChanged,
    required this.year,
    required this.onYearChanged,
    required this.country,
    required this.onCountryChanged,
  });

  final String? coverImageId;
  final bool processing;
  final VoidCallback onPickCover;
  final VoidCallback onRemoveCover;
  final TextEditingController originalController;
  final ValueChanged<String> onOriginalChanged;
  final int? year;
  final ValueChanged<int?> onYearChanged;
  final String? country;
  final ValueChanged<String?> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CoverThumb(
          coverImageId: coverImageId,
          processing: processing,
          onPick: onPickCover,
          onRemove: onRemoveCover,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: originalController,
                onChanged: onOriginalChanged,
                onTapOutside: dismissKeyboardOnTapOutside,
                maxLength: 100,
                buildCounter: coloredCharCounter,
                style: TextStyle(
                  fontSize: 14 * uiScale,
                  fontStyle: FontStyle.italic,
                  color: context.tokens.onBg,
                ),
                decoration: editorFieldDecoration(
                  context,
                  hint: 'Оригинальное название',
                  italicHint: true,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  SizedBox(
                    width: 104,
                    child: YearField(value: year, onChanged: onYearChanged),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: CountryField(
                        value: country, onChanged: onCountryChanged),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
      width: 76,
      height: 104,
      child: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              button: true,
              label: has ? 'Заменить обложку' : 'Добавить обложку',
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
                label: 'Убрать обложку',
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

// ─────────────────────────── условный блок: серии ────────────────────────

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.state, required this.cubit});

  final MediaEditorState state;
  final MediaEditorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return EditorConditionalCard(
      title: 'Прогресс серий',
      badge: 'только для сериалов',
      accent: context.tokens.primary,
      // 2×2 парами (текущее ↔ всего) — чтобы «Всего сезонов» не торчал один.
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MiniStepper(
                  label: 'Сезон',
                  value: state.currentSeason,
                  onChanged: cubit.setCurrentSeason,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: MiniStepper(
                  label: 'Всего сезонов',
                  value: state.totalSeasons,
                  onChanged: cubit.setTotalSeasons,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: MiniStepper(
                  label: 'Серия',
                  value: state.currentEpisode,
                  onChanged: cubit.setCurrentEpisode,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: MiniStepper(
                  label: 'Всего серий',
                  value: state.totalEpisodes,
                  onChanged: cubit.setTotalEpisodes,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── условный блок: причина ──────────────────────

class _ReasonBlock extends StatelessWidget {
  const _ReasonBlock({required this.state, required this.cubit});

  final MediaEditorState state;
  final MediaEditorCubit cubit;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final paused = tk.statusColor(WatchStatus.paused);
    return EditorConditionalCard(
      title: 'Причина паузы',
      badge: 'пауза / заброшено',
      accent: paused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final reason in UnfinishedReason.values)
                // «Жду серии» — только при паузе + episodic (ADR-08).
                if (reason != UnfinishedReason.waitingEpisodes ||
                    state.canOfferWaiting)
                  EditorChip(
                    label: reasonLabel(reason),
                    accent: paused,
                    icon: reason == UnfinishedReason.waitingEpisodes
                        ? Icons.hourglass_bottom_rounded
                        : null,
                    selected: state.unfinishedReason == reason,
                    onTap: () => cubit.setUnfinishedReason(
                      state.unfinishedReason == reason ? null : reason,
                    ),
                  ),
            ],
          ),
          if (state.canOfferWaiting) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: paused),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '«Жду серии» → карточка попадёт на полку ожидания',
                    style: TextStyle(
                      fontSize: 11 * uiScale,
                      color: tk.onMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
import '../widgets/editor/catalog_date_field.dart';
import '../widgets/editor/country_field.dart';
import '../widgets/editor/editor_primitives.dart';
import '../widgets/editor/rating_input.dart';
import '../widgets/editor/tag_editor.dart';

/// Экран 03 — создание/редактирование карточки медиа (прогрессивное раскрытие).
/// Без go_router (A4 отложен) — открывается `Navigator.push(MediaEditorPage.route())`.
class MediaEditorPage extends StatelessWidget {
  const MediaEditorPage({super.key, this.entryId});

  /// `null` — создание новой; иначе — редактирование существующей карточки.
  final String? entryId;

  static Route<void> route({String? entryId}) => MaterialPageRoute(
        builder: (_) => MediaEditorPage(entryId: entryId),
      );

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
        builder: (context, state) => state.loading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : const _EditorForm(),
      ),
    );
  }
}

class _EditorForm extends StatefulWidget {
  const _EditorForm();

  @override
  State<_EditorForm> createState() => _EditorFormState();
}

class _EditorFormState extends State<_EditorForm> {
  late final TextEditingController _title;
  late final TextEditingController _original;
  late final TextEditingController _year;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final s = context.read<MediaEditorCubit>().state;
    _title = TextEditingController(text: s.title);
    _original = TextEditingController(text: s.originalTitle ?? '');
    _year = TextEditingController(text: s.year?.toString() ?? '');
    _note = TextEditingController(text: s.note ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _original.dispose();
    _year.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    final cubit = context.read<MediaEditorCubit>();
    final s = cubit.state;
    // Спрашиваем подтверждение только при создании с непустым вводом.
    if (s.mode == EditorMode.create && s.title.trim().isNotEmpty) {
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
      if (discard != true) return;
    }
    if (mounted) Navigator.of(context).pop();
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
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: state.mode == EditorMode.create
                      ? 'Новая карточка'
                      : 'Редактирование',
                  canSave: state.canSave,
                  saving: state.saving,
                  onClose: _close,
                  onSave: cubit.save,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                    children: [
                      _required(context, state, cubit),
                      const _GroupGap(),
                      const Divider(height: 1),
                      const _GroupGap(),
                      _main(context, state, cubit),
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
                      const _GroupGap(),
                      _dates(context, state, cubit),
                      const _GroupGap(),
                      _noteField(context, cubit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────── секция 1 · обязательно ───────────────────────

  Widget _required(
      BuildContext context, MediaEditorState state, MediaEditorCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditorSectionHeader(index: 1, label: 'Обязательно', accent: true),
        const EditorLabel('Тип'),
        EditorSegments<MediaType>(
          value: state.mediaType,
          onChanged: cubit.setMediaType,
          options: const [
            (MediaType.movie, 'Фильм'),
            (MediaType.series, 'Сериал'),
            (MediaType.anime, 'Аниме'),
            (MediaType.drama, 'Дорама'),
          ],
        ),
        const SizedBox(height: 11),
        const EditorLabel('Формат'),
        EditorSegments<MediaFormat>(
          value: state.format,
          onChanged: cubit.setFormat,
          options: const [
            (MediaFormat.single, 'Одиночный'),
            (MediaFormat.episodic, 'С сериями'),
          ],
        ),
        const SizedBox(height: 11),
        const EditorLabel('Название', required: true),
        TextField(
          controller: _title,
          onChanged: cubit.setTitle,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            fontSize: 14.5 * uiScale,
            fontWeight: FontWeight.w600,
            color: context.tokens.onBg,
          ),
          decoration: editorFieldDecoration(context, hint: 'Название'),
        ),
        const SizedBox(height: 11),
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
      ],
    );
  }

  // ─────────────────────────── секция 2 · основное ──────────────────────────

  Widget _main(
      BuildContext context, MediaEditorState state, MediaEditorCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditorSectionHeader(index: 2, label: 'Основное'),
        TextField(
          controller: _original,
          onChanged: cubit.setOriginalTitle,
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
        const SizedBox(height: 11),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _year,
                onChanged: (v) => cubit.setYear(int.tryParse(v.trim())),
                keyboardType: TextInputType.number,
                maxLength: 4,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 14 * uiScale, color: context.tokens.onBg),
                decoration: editorFieldDecoration(context, hint: 'Год'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              flex: 3,
              child: CountryField(
                value: state.country,
                onChanged: cubit.setCountry,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        const EditorLabel('Обложка'),
        _CoverField(
          coverImageId: state.coverImageId,
          processing: state.processingImage,
          onPick: () => _pickCover(context),
          onRemove: cubit.removeCover,
        ),
        const SizedBox(height: 11),
        RatingInput(value: state.rating, onChanged: cubit.setRating),
        const SizedBox(height: 14),
        const EditorLabel('Теги'),
        TagEditor(
          allTags: state.allTags,
          selectedIds: state.selectedTagIds,
          onToggle: cubit.toggleTag,
          onCreate: cubit.addTag,
        ),
      ],
    );
  }

  // ─────────────────────────── даты ─────────────────────────────────────────

  Widget _dates(
      BuildContext context, MediaEditorState state, MediaEditorCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditorSectionHeader(index: 3, label: 'Даты'),
        CatalogDateField(
          label: 'Дата начала',
          value: state.startedAt,
          onChanged: (d) => cubit.setDate(EditorDateSlot.started, d),
        ),
        const SizedBox(height: 14),
        CatalogDateField(
          label: 'Последний просмотр',
          value: state.lastActivityAt,
          onChanged: (d) => cubit.setDate(EditorDateSlot.lastActivity, d),
        ),
        const SizedBox(height: 14),
        CatalogDateField(
          label: 'Дата завершения',
          value: state.finishedAt,
          onChanged: (d) => cubit.setDate(EditorDateSlot.finished, d),
        ),
      ],
    );
  }

  Widget _noteField(BuildContext context, MediaEditorCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditorLabel('Заметка'),
        TextField(
          controller: _note,
          onChanged: cubit.setNote,
          minLines: 3,
          maxLines: 6,
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

class _GroupGap extends StatelessWidget {
  const _GroupGap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 18);
}

// ─────────────────────────── обложка ─────────────────────────────────────

class _CoverField extends StatelessWidget {
  const _CoverField({
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
    final text = Theme.of(context).textTheme;
    final hasCover = coverImageId != null;
    return Row(
      children: [
        GestureDetector(
          onTap: processing ? null : onPick,
          child: Container(
            width: 84,
            height: 118,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: tk.surface,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: tk.outlineSoft),
            ),
            child: processing
                ? const Center(
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : hasCover
                    ? Image.file(
                        getIt<MediaPaths>().absFull(coverImageId!),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, _, _) => Icon(
                            Icons.broken_image_outlined, color: tk.onFaint),
                      )
                    : Icon(Icons.add_photo_alternate_outlined,
                        size: 28, color: tk.onFaint),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: hasCover
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CoverAction(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Заменить',
                        onTap: onPick),
                    _CoverAction(
                        icon: Icons.delete_outline_rounded,
                        label: 'Убрать',
                        color: tk.error,
                        onTap: onRemove),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Добавить обложку', style: text.titleSmall),
                    const SizedBox(height: 3),
                    Text('Из галереи или камеры', style: text.bodySmall),
                  ],
                ),
        ),
      ],
    );
  }
}

class _CoverAction extends StatelessWidget {
  const _CoverAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.tokens.onMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: c),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13 * uiScale,
                    fontWeight: FontWeight.w600,
                    color: c)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── верхний бар ─────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.canSave,
    required this.saving,
    required this.onClose,
    required this.onSave,
  });

  final String title;
  final bool canSave;
  final bool saving;
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Row(
        children: [
          Material(
            color: tk.surface,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onClose,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close_rounded, size: 20, color: tk.onBg),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15 * uiScale,
                fontWeight: FontWeight.w700,
                color: tk.onBg,
              ),
            ),
          ),
          _SaveButton(enabled: canSave, saving: saving, onTap: onSave),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
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
    return Material(
      color: enabled ? tk.primary : tk.tint(tk.primary, 0.30),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: saving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tk.onPrimary,
                  ),
                )
              : Text(
                  'Сохранить',
                  style: TextStyle(
                    fontSize: 13.5 * uiScale,
                    fontWeight: FontWeight.w700,
                    color: enabled ? tk.onPrimary : tk.onFaint,
                  ),
                ),
        ),
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
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: MiniStepper(
                  label: 'Всего сезонов',
                  value: state.totalSeasons,
                  onChanged: cubit.setTotalSeasons,
                ),
              ),
              const Spacer(flex: 2),
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

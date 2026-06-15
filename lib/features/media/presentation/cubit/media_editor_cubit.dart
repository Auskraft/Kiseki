import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/catalog_date.dart';
import '../../../../core/catalog/rating.dart';
import '../../../../core/catalog/tag.dart';
import '../../../../core/catalog/tag_repository.dart';
import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/images/image_storage.dart';
import '../../domain/media_draft.dart';
import '../../domain/media_format.dart';
import '../../domain/media_repository.dart';
import '../../domain/media_type.dart';

enum EditorMode { create, edit }

/// Слот пользовательской даты (которой из трёх управляет поле).
enum EditorDateSlot { started, lastActivity, finished }

/// Состояние формы создания/редактирования карточки. Хранит редактируемые
/// поля как примитивы (оценка — `int?`, не [Rating]); доменный [MediaDraft]
/// собирается на сохранении с CHECK-безопасной нормализацией.
class MediaEditorState extends Equatable {
  const MediaEditorState({
    required this.mode,
    this.entryId,
    this.title = '',
    this.mediaType,
    this.format,
    this.status = WatchStatus.plan,
    this.rating,
    this.originalTitle,
    this.year,
    this.country,
    this.currentSeason,
    this.currentEpisode,
    this.totalSeasons,
    this.totalEpisodes,
    this.unfinishedReason,
    this.startedAt,
    this.lastActivityAt,
    this.finishedAt,
    this.note,
    this.isFavorite = false,
    this.rewatchCount = 0,
    this.selectedTagIds = const {},
    this.allTags = const [],
    this.coverImageId,
    this.processingImage = false,
    this.loading = false,
    this.saving = false,
    this.justSaved = false,
    this.errorMessage,
  });

  final EditorMode mode;
  final String? entryId;

  final String title;

  /// `null` — вид ещё не выбран (форма раскрывается прогрессивно: Формат → Тип).
  final MediaType? mediaType;

  /// `null` — формат ещё не выбран (выбирается первым).
  final MediaFormat? format;

  final WatchStatus status;

  /// Оценка 0–100; `null` = «не оценено».
  final int? rating;
  final String? originalTitle;
  final int? year;

  /// ISO 3166-1 alpha-2 (`KR`, `JP`…), `null` если не указана.
  final String? country;

  final int? currentSeason;
  final int? currentEpisode;
  final int? totalSeasons;
  final int? totalEpisodes;

  final UnfinishedReason? unfinishedReason;

  final CatalogDate? startedAt;
  final CatalogDate? lastActivityAt;
  final CatalogDate? finishedAt;

  final String? note;
  final bool isFavorite;
  final int rewatchCount;

  final Set<String> selectedTagIds;

  /// Все теги справочника + число живых карточек (для популярных чипов).
  final List<TagWithCount> allTags;

  /// UUID обложки (файлы уже сохранены) или `null`.
  final String? coverImageId;

  /// Идёт сжатие/сохранение выбранной картинки.
  final bool processingImage;

  final bool loading;
  final bool saving;

  /// Поднимается после успешного сохранения — сигнал экрану закрыться.
  final bool justSaved;

  /// Транзиентное сообщение об ошибке сохранения (показать и сбросить).
  final String? errorMessage;

  bool get isEpisodic => format == MediaFormat.episodic;

  /// Блок причины показывается на паузе/забросе (TECH_DESIGN §6.3).
  bool get showReason =>
      status == WatchStatus.paused || status == WatchStatus.dropped;

  /// «Жду серии» доступно только при `paused` + `episodic` (ADR-08).
  bool get canOfferWaiting => status == WatchStatus.paused && isEpisodic;

  // !processingImage: иначе Save во время сжатия только что выбранной обложки
  // сохранил бы карточку без неё (новый id ещё не в state), а файл осиротел.
  bool get canSave =>
      title.trim().isNotEmpty &&
      format != null &&
      mediaType != null &&
      !saving &&
      !processingImage;

  CatalogDate? dateFor(EditorDateSlot slot) => switch (slot) {
        EditorDateSlot.started => startedAt,
        EditorDateSlot.lastActivity => lastActivityAt,
        EditorDateSlot.finished => finishedAt,
      };

  MediaEditorState copyWith({
    String? title,
    MediaType? mediaType,
    MediaFormat? format,
    WatchStatus? status,
    ValueGetter<int?>? rating,
    ValueGetter<String?>? originalTitle,
    ValueGetter<int?>? year,
    ValueGetter<String?>? country,
    ValueGetter<int?>? currentSeason,
    ValueGetter<int?>? currentEpisode,
    ValueGetter<int?>? totalSeasons,
    ValueGetter<int?>? totalEpisodes,
    ValueGetter<UnfinishedReason?>? unfinishedReason,
    ValueGetter<CatalogDate?>? startedAt,
    ValueGetter<CatalogDate?>? lastActivityAt,
    ValueGetter<CatalogDate?>? finishedAt,
    ValueGetter<String?>? note,
    bool? isFavorite,
    int? rewatchCount,
    Set<String>? selectedTagIds,
    List<TagWithCount>? allTags,
    ValueGetter<String?>? coverImageId,
    bool? processingImage,
    bool? loading,
    bool? saving,
    bool? justSaved,
    ValueGetter<String?>? errorMessage,
  }) {
    return MediaEditorState(
      mode: mode,
      entryId: entryId,
      title: title ?? this.title,
      mediaType: mediaType ?? this.mediaType,
      format: format ?? this.format,
      status: status ?? this.status,
      rating: rating != null ? rating() : this.rating,
      originalTitle:
          originalTitle != null ? originalTitle() : this.originalTitle,
      year: year != null ? year() : this.year,
      country: country != null ? country() : this.country,
      currentSeason:
          currentSeason != null ? currentSeason() : this.currentSeason,
      currentEpisode:
          currentEpisode != null ? currentEpisode() : this.currentEpisode,
      totalSeasons: totalSeasons != null ? totalSeasons() : this.totalSeasons,
      totalEpisodes:
          totalEpisodes != null ? totalEpisodes() : this.totalEpisodes,
      unfinishedReason: unfinishedReason != null
          ? unfinishedReason()
          : this.unfinishedReason,
      startedAt: startedAt != null ? startedAt() : this.startedAt,
      lastActivityAt:
          lastActivityAt != null ? lastActivityAt() : this.lastActivityAt,
      finishedAt: finishedAt != null ? finishedAt() : this.finishedAt,
      note: note != null ? note() : this.note,
      isFavorite: isFavorite ?? this.isFavorite,
      rewatchCount: rewatchCount ?? this.rewatchCount,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      allTags: allTags ?? this.allTags,
      coverImageId:
          coverImageId != null ? coverImageId() : this.coverImageId,
      processingImage: processingImage ?? this.processingImage,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      justSaved: justSaved ?? this.justSaved,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        entryId,
        title,
        mediaType,
        format,
        status,
        rating,
        originalTitle,
        year,
        country,
        currentSeason,
        currentEpisode,
        totalSeasons,
        totalEpisodes,
        unfinishedReason,
        startedAt,
        lastActivityAt,
        finishedAt,
        note,
        isFavorite,
        rewatchCount,
        selectedTagIds,
        allTags,
        coverImageId,
        processingImage,
        loading,
        saving,
        justSaved,
        errorMessage,
      ];
}

/// Состояние формы карточки. Реактивно открывает блоки (серии — при
/// `episodic`, причина — при `paused`/`dropped`) и собирает [MediaDraft]
/// для репозитория. В edit-режиме подгружает существующую запись.
class MediaEditorCubit extends Cubit<MediaEditorState> {
  MediaEditorCubit(this._repo, this._tags, this._images, {String? entryId})
      : super(MediaEditorState(
          mode: entryId == null ? EditorMode.create : EditorMode.edit,
          entryId: entryId,
          loading: entryId != null,
        )) {
    _tagsSub = _tags.watchAllWithCounts().listen(
          (tags) => emit(state.copyWith(allTags: tags)),
        );
    if (entryId != null) _load(entryId);
  }

  final MediaRepository _repo;
  final TagRepository _tags;
  final ImageStorage _images;
  late final StreamSubscription<List<TagWithCount>> _tagsSub;

  /// Обложка, лежащая в БД на момент загрузки (для очистки файлов при замене).
  String? _loadedCoverId;

  Future<void> _load(String id) async {
    final e = await _repo.findById(id);
    if (isClosed) return;
    if (e == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    emit(MediaEditorState(
      mode: EditorMode.edit,
      entryId: id,
      title: e.title,
      mediaType: e.mediaType,
      format: e.format,
      status: e.status,
      rating: e.rating?.value,
      originalTitle: e.originalTitle,
      year: e.year,
      country: e.country,
      currentSeason: e.currentSeason,
      currentEpisode: e.currentEpisode,
      totalSeasons: e.totalSeasons,
      totalEpisodes: e.totalEpisodes,
      unfinishedReason: e.unfinishedReason,
      startedAt: e.startedAt,
      lastActivityAt: e.lastActivityAt,
      finishedAt: e.finishedAt,
      note: e.note,
      isFavorite: e.isFavorite,
      rewatchCount: e.rewatchCount,
      selectedTagIds: e.tags.map((t) => t.id).toSet(),
      allTags: state.allTags,
      coverImageId: e.cover?.id,
      loading: false,
    ));
    _loadedCoverId = e.cover?.id;
  }

  /// Сжимает и сохраняет выбранную картинку (файлы на диск, §7.3) и делает её
  /// обложкой. Прежнюю СТАГНУТУЮ (не из БД) обложку удаляет — она осиротела.
  Future<void> attachCover(String sourcePath) async {
    emit(state.copyWith(processingImage: true, errorMessage: () => null));
    try {
      final newId = await _images.save(sourcePath);
      if (isClosed) return;
      final prev = state.coverImageId;
      emit(state.copyWith(
        coverImageId: () => newId,
        processingImage: false,
      ));
      if (prev != null && prev != _loadedCoverId) {
        await _images.deleteFiles(prev);
      }
    } on Failure catch (e) {
      // Типизированная причина (слишком большой / не распознан) — в текст.
      if (isClosed) return;
      emit(state.copyWith(processingImage: false, errorMessage: () => e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        processingImage: false,
        errorMessage: () => 'Не удалось обработать картинку',
      ));
    }
  }

  Future<void> removeCover() async {
    final prev = state.coverImageId;
    emit(state.copyWith(coverImageId: () => null));
    if (prev != null && prev != _loadedCoverId) {
      await _images.deleteFiles(prev);
    }
  }

  void setTitle(String v) => emit(state.copyWith(title: v));

  /// Смена вида НЕ трогает формат — он выбирается отдельно (Одиночный/
  /// Серийный) и несёт эпизодность (ADR-07).
  void setMediaType(MediaType type) => emit(state.copyWith(mediaType: type));

  void setFormat(MediaFormat format) => emit(state.copyWith(format: format));

  /// Смена статуса нормализует причину: вне паузы/заброса — снимается;
  /// «жду серии» осмысленно только на паузе.
  void setStatus(WatchStatus status) {
    final keepReason = status == WatchStatus.paused ||
        status == WatchStatus.dropped;
    var reason = keepReason ? state.unfinishedReason : null;
    if (reason == UnfinishedReason.waitingEpisodes &&
        status != WatchStatus.paused) {
      reason = null;
    }
    emit(state.copyWith(status: status, unfinishedReason: () => reason));
  }

  void setRating(int? value) => emit(state.copyWith(
        rating: () => value?.clamp(0, 100),
      ));

  void setOriginalTitle(String v) =>
      emit(state.copyWith(originalTitle: () => v));

  void setYear(int? v) => emit(state.copyWith(year: () => v));

  void setCountry(String? code) => emit(state.copyWith(country: () => code));

  /// Серия требует сезон (CHECK): при заданной серии без сезона ставим S1.
  void setCurrentEpisode(int? v) => emit(state.copyWith(
        currentEpisode: () => v,
        currentSeason: () =>
            v != null && state.currentSeason == null ? 1 : state.currentSeason,
      ));

  void setCurrentSeason(int? v) => emit(state.copyWith(currentSeason: () => v));

  void setTotalSeasons(int? v) => emit(state.copyWith(totalSeasons: () => v));

  void setTotalEpisodes(int? v) => emit(state.copyWith(totalEpisodes: () => v));

  void setUnfinishedReason(UnfinishedReason? reason) =>
      emit(state.copyWith(unfinishedReason: () => reason));

  void setDate(EditorDateSlot slot, CatalogDate? date) {
    switch (slot) {
      case EditorDateSlot.started:
        emit(state.copyWith(startedAt: () => date));
      case EditorDateSlot.lastActivity:
        emit(state.copyWith(lastActivityAt: () => date));
      case EditorDateSlot.finished:
        emit(state.copyWith(finishedAt: () => date));
    }
  }

  void setNote(String v) => emit(state.copyWith(note: () => v));

  void toggleTag(String tagId) {
    final next = {...state.selectedTagIds};
    if (!next.remove(tagId)) next.add(tagId);
    emit(state.copyWith(selectedTagIds: next));
  }

  /// Создаёт (или находит существующий) тег и сразу выбирает его.
  Future<void> addTag(String name) async {
    if (name.trim().isEmpty) return;
    final tag = await _tags.ensure(name);
    if (isClosed) return;
    emit(state.copyWith(selectedTagIds: {...state.selectedTagIds, tag.id}));
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(saving: true, errorMessage: () => null));
    try {
      final draft = _buildDraft();
      if (state.mode == EditorMode.edit && state.entryId != null) {
        await _repo.update(state.entryId!, draft);
      } else {
        await _repo.create(draft);
      }
      // Старая обложка из БД заменена/убрана → чистим её файлы (после коммита).
      final old = _loadedCoverId;
      if (old != null && old != state.coverImageId) {
        await _images.deleteFiles(old);
      }
      _loadedCoverId = state.coverImageId;
      if (isClosed) return;
      emit(state.copyWith(saving: false, justSaved: true));
    } on Failure catch (e) {
      if (isClosed) return;
      emit(state.copyWith(saving: false, errorMessage: () => e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        saving: false,
        errorMessage: () => 'Не удалось сохранить карточку',
      ));
    }
  }

  /// Собирает доменный драфт, гарантируя инварианты схемы (CHECK):
  /// сезонные поля только у `episodic`; серия влечёт сезон; причина —
  /// только при паузе/забросе; «жду серии» — только пауза.
  MediaDraft _buildDraft() {
    final episodic = state.format == MediaFormat.episodic;

    var season = episodic ? state.currentSeason : null;
    final episode = episodic ? state.currentEpisode : null;
    final totalSeasons = episodic ? state.totalSeasons : null;
    final totalEpisodes = episodic ? state.totalEpisodes : null;
    if (episode != null && season == null) season = 1;

    var reason = state.unfinishedReason;
    if (state.status != WatchStatus.paused &&
        state.status != WatchStatus.dropped) {
      reason = null;
    }
    if (reason == UnfinishedReason.waitingEpisodes &&
        !(state.status == WatchStatus.paused && episodic)) {
      reason = null;
    }

    return MediaDraft(
      title: state.title.trim(),
      mediaType: state.mediaType!,
      format: state.format!,
      status: state.status,
      rating: state.rating == null ? null : Rating.clamp(state.rating!),
      unfinishedReason: reason,
      note: _nullIfBlank(state.note),
      isFavorite: state.isFavorite,
      rewatchCount: state.rewatchCount,
      originalTitle: _nullIfBlank(state.originalTitle),
      year: state.year,
      country: state.country,
      currentSeason: season,
      currentEpisode: episode,
      totalSeasons: totalSeasons,
      totalEpisodes: totalEpisodes,
      startedAt: state.startedAt,
      lastActivityAt: state.lastActivityAt,
      finishedAt: state.finishedAt,
      tagIds: state.selectedTagIds.toList(),
      coverImageId: state.coverImageId,
    );
  }

  static String? _nullIfBlank(String? s) {
    final t = s?.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  @override
  Future<void> close() async {
    await _tagsSub.cancel();
    // Отмена формы: стагнутая (не сохранённая) обложка осиротела — удаляем.
    // НО не во время сохранения (state.saving): иначе при системном «назад»
    // в момент коммита мы бы удалили файлы, на которые сошлётся сохранённая
    // карточка (битая обложка, не чинится sweeper'ом — id живой).
    final staged = state.coverImageId;
    if (!state.justSaved &&
        !state.saving &&
        staged != null &&
        staged != _loadedCoverId) {
      await _images.deleteFiles(staged);
    }
    return super.close();
  }
}

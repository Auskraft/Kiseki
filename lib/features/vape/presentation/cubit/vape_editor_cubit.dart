import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/catalog_date.dart';
import '../../../../core/catalog/date_precision.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/images/image_storage.dart';
import '../../domain/flavor_category.dart';
import '../../domain/nicotine_strengths.dart';
import '../../domain/nicotine_type.dart';
import '../../domain/vape_draft.dart';
import '../../domain/vape_repository.dart';

enum EditorMode { create, edit }

/// Состояние формы жидкости. Поля — примитивы; [VapeDraft] собирается на
/// сохранении. Обязательны: бренд, название вкуса, тип и крепость никотина.
class VapeEditorState extends Equatable {
  const VapeEditorState({
    required this.mode,
    this.entryId,
    this.title = '',
    this.brand = '',
    this.nicotineType,
    this.nicotineStrength,
    this.rating,
    this.note,
    this.addedAt,
    this.flavorCategory,
    this.flavorDescription,
    this.sweetness,
    this.coolness,
    this.richness,
    this.canRebuy = false,
    this.flavorFades = false,
    this.damagesHardware = false,
    this.coverImageId,
    this.processingImage = false,
    this.loading = false,
    this.saving = false,
    this.justSaved = false,
    this.errorMessage,
  });

  final EditorMode mode;
  final String? entryId;

  final String title; // название вкуса
  final String brand;
  final NicotineType? nicotineType;
  final String? nicotineStrength;
  final int? rating; // общая оценка вкуса 0–100
  final String? note; // комментарий
  final CatalogDate? addedAt; // дата добавления

  final FlavorCategory? flavorCategory;
  final String? flavorDescription;
  final int? sweetness;
  final int? coolness;
  final int? richness;
  final bool canRebuy;
  final bool flavorFades;
  final bool damagesHardware;

  final String? coverImageId;
  final bool processingImage;
  final bool loading;
  final bool saving;
  final bool justSaved;
  final String? errorMessage;

  bool get canSave =>
      brand.trim().isNotEmpty &&
      title.trim().isNotEmpty &&
      nicotineType != null &&
      nicotineStrength != null &&
      !saving &&
      !processingImage;

  VapeEditorState copyWith({
    String? title,
    String? brand,
    NicotineType? nicotineType,
    ValueGetter<String?>? nicotineStrength,
    ValueGetter<int?>? rating,
    ValueGetter<String?>? note,
    ValueGetter<CatalogDate?>? addedAt,
    ValueGetter<FlavorCategory?>? flavorCategory,
    ValueGetter<String?>? flavorDescription,
    ValueGetter<int?>? sweetness,
    ValueGetter<int?>? coolness,
    ValueGetter<int?>? richness,
    bool? canRebuy,
    bool? flavorFades,
    bool? damagesHardware,
    ValueGetter<String?>? coverImageId,
    bool? processingImage,
    bool? loading,
    bool? saving,
    bool? justSaved,
    ValueGetter<String?>? errorMessage,
  }) {
    return VapeEditorState(
      mode: mode,
      entryId: entryId,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      nicotineType: nicotineType ?? this.nicotineType,
      nicotineStrength:
          nicotineStrength != null ? nicotineStrength() : this.nicotineStrength,
      rating: rating != null ? rating() : this.rating,
      note: note != null ? note() : this.note,
      addedAt: addedAt != null ? addedAt() : this.addedAt,
      flavorCategory:
          flavorCategory != null ? flavorCategory() : this.flavorCategory,
      flavorDescription: flavorDescription != null
          ? flavorDescription()
          : this.flavorDescription,
      sweetness: sweetness != null ? sweetness() : this.sweetness,
      coolness: coolness != null ? coolness() : this.coolness,
      richness: richness != null ? richness() : this.richness,
      canRebuy: canRebuy ?? this.canRebuy,
      flavorFades: flavorFades ?? this.flavorFades,
      damagesHardware: damagesHardware ?? this.damagesHardware,
      coverImageId: coverImageId != null ? coverImageId() : this.coverImageId,
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
        brand,
        nicotineType,
        nicotineStrength,
        rating,
        note,
        addedAt,
        flavorCategory,
        flavorDescription,
        sweetness,
        coolness,
        richness,
        canRebuy,
        flavorFades,
        damagesHardware,
        coverImageId,
        processingImage,
        loading,
        saving,
        justSaved,
        errorMessage,
      ];
}

/// Форма создания/редактирования жидкости. В create-режиме «Дата добавления»
/// по умолчанию = сегодня (точность «день», UTC — TZ-стабильно).
class VapeEditorCubit extends Cubit<VapeEditorState> {
  VapeEditorCubit(this._repo, this._images, {String? entryId})
      : super(_initial(entryId)) {
    if (entryId != null) _load(entryId);
  }

  final VapeRepository _repo;
  final ImageStorage _images;

  String? _loadedCoverId;

  static VapeEditorState _initial(String? entryId) {
    if (entryId != null) {
      return VapeEditorState(
          mode: EditorMode.edit, entryId: entryId, loading: true);
    }
    final n = DateTime.now();
    return VapeEditorState(
      mode: EditorMode.create,
      addedAt: CatalogDate(
          DateTime.utc(n.year, n.month, n.day), DatePrecision.day),
    );
  }

  Future<void> _load(String id) async {
    final e = await _repo.findById(id);
    if (isClosed) return;
    if (e == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    emit(VapeEditorState(
      mode: EditorMode.edit,
      entryId: id,
      title: e.title,
      brand: e.brand,
      nicotineType: e.nicotineType,
      nicotineStrength: e.nicotineStrength,
      rating: e.rating,
      note: e.note,
      addedAt: e.addedAt,
      flavorCategory: e.flavorCategory,
      flavorDescription: e.flavorDescription,
      sweetness: e.sweetness,
      coolness: e.coolness,
      richness: e.richness,
      canRebuy: e.canRebuy,
      flavorFades: e.flavorFades,
      damagesHardware: e.damagesHardware,
      coverImageId: e.cover?.id,
      loading: false,
    ));
    _loadedCoverId = e.cover?.id;
  }

  void setBrand(String v) => emit(state.copyWith(brand: v));
  void setTitle(String v) => emit(state.copyWith(title: v));

  /// Смена типа: если текущая крепость не входит в список нового типа — сбросить.
  void setNicotineType(NicotineType type) {
    final keep = nicotineStrengthsFor(type).contains(state.nicotineStrength);
    emit(state.copyWith(
      nicotineType: type,
      nicotineStrength: keep ? null : () => null,
    ));
  }

  void setNicotineStrength(String? v) =>
      emit(state.copyWith(nicotineStrength: () => v));
  void setRating(int? v) =>
      emit(state.copyWith(rating: () => v?.clamp(0, 100)));
  void setNote(String v) => emit(state.copyWith(note: () => v));
  void setAddedAt(CatalogDate? d) => emit(state.copyWith(addedAt: () => d));
  void setFlavorCategory(FlavorCategory? c) =>
      emit(state.copyWith(flavorCategory: () => c));
  void setFlavorDescription(String v) =>
      emit(state.copyWith(flavorDescription: () => v));
  void setSweetness(int? v) => emit(state.copyWith(sweetness: () => v));
  void setCoolness(int? v) => emit(state.copyWith(coolness: () => v));
  void setRichness(int? v) => emit(state.copyWith(richness: () => v));
  void setCanRebuy(bool v) => emit(state.copyWith(canRebuy: v));
  void setFlavorFades(bool v) => emit(state.copyWith(flavorFades: v));
  void setDamagesHardware(bool v) =>
      emit(state.copyWith(damagesHardware: v));

  Future<void> attachCover(String sourcePath) async {
    emit(state.copyWith(processingImage: true, errorMessage: () => null));
    try {
      final newId = await _images.save(sourcePath);
      if (isClosed) return;
      final prev = state.coverImageId;
      emit(state.copyWith(coverImageId: () => newId, processingImage: false));
      if (prev != null && prev != _loadedCoverId) {
        await _images.deleteFiles(prev);
      }
    } on Failure catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
          processingImage: false, errorMessage: () => e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        processingImage: false,
        errorMessage: () => 'Не удалось обработать фото',
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

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(saving: true, errorMessage: () => null));
    try {
      final draft = VapeDraft(
        title: state.title.trim(),
        brand: state.brand.trim(),
        nicotineType: state.nicotineType!,
        nicotineStrength: state.nicotineStrength!,
        rating: state.rating,
        note: _nullIfBlank(state.note),
        addedAt: state.addedAt,
        flavorCategory: state.flavorCategory,
        flavorDescription: _nullIfBlank(state.flavorDescription),
        sweetness: state.sweetness,
        coolness: state.coolness,
        richness: state.richness,
        canRebuy: state.canRebuy,
        flavorFades: state.flavorFades,
        damagesHardware: state.damagesHardware,
        coverImageId: state.coverImageId,
      );
      if (state.mode == EditorMode.edit && state.entryId != null) {
        await _repo.update(state.entryId!, draft);
      } else {
        await _repo.create(draft);
      }
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
        errorMessage: () => 'Не удалось сохранить',
      ));
    }
  }

  static String? _nullIfBlank(String? s) {
    final t = s?.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  @override
  Future<void> close() async {
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

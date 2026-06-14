import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_repository.dart';

class MediaDetailState extends Equatable {
  const MediaDetailState({this.entry, this.loading = true});

  final MediaEntry? entry;
  final bool loading;

  /// Запись не найдена (удалена физически / неверный id).
  bool get notFound => !loading && entry == null;

  @override
  List<Object?> get props => [entry, loading];
}

/// Деталь карточки: реактивно следит за одной записью (`watchById`) и
/// выполняет быстрые действия. Мутации не эмитят состояние сами —
/// обновление прилетает обратно через стрим (single source of truth).
class MediaDetailCubit extends Cubit<MediaDetailState> {
  MediaDetailCubit(this._repo, this.id) : super(const MediaDetailState()) {
    _sub = _repo.watchById(id).listen(
          (e) => emit(MediaDetailState(entry: e, loading: false)),
        );
  }

  final MediaRepository _repo;
  final String id;
  late final StreamSubscription<MediaEntry?> _sub;

  Future<void> setStatus(WatchStatus status, {UnfinishedReason? reason}) =>
      _repo.setStatus(id, status, unfinishedReason: reason);

  Future<void> toggleFavorite() {
    final e = state.entry;
    if (e == null) return Future.value();
    return _repo.setFavorite(id, !e.isFavorite);
  }

  Future<void> incrementEvent() => _repo.incrementEventCount(id);

  Future<void> softDelete() => _repo.softDelete(id);

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/media_entry.dart';
import '../../domain/media_query.dart';
import '../../domain/media_repository.dart';

class MediaTrashState extends Equatable {
  const MediaTrashState({this.items = const [], this.loading = true});

  final List<MediaEntry> items;
  final bool loading;

  bool get isEmpty => !loading && items.isEmpty;

  @override
  List<Object?> get props => [items, loading];
}

/// Корзина: реактивный список мягко-удалённых карточек (`deleted_at IS NOT NULL`).
/// Действия (восстановить / удалить навсегда / очистить) меняют данные —
/// список пере-эмитит сам через стрим.
class MediaTrashCubit extends Cubit<MediaTrashState> {
  MediaTrashCubit(this._repo) : super(const MediaTrashState()) {
    _sub = _repo
        .watch(const MediaListQuery(includeDeleted: true))
        .listen((items) => emit(MediaTrashState(items: items, loading: false)));
  }

  final MediaRepository _repo;
  late final StreamSubscription<List<MediaEntry>> _sub;

  Future<void> restore(String id) => _repo.restore(id);

  Future<void> purge(String id) => _repo.purge(id);

  Future<void> purgeAll() => _repo.purgeAllTrashed();

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

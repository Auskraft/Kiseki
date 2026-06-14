import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/images/image_storage.dart';
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
  MediaTrashCubit(this._repo, this._images) : super(const MediaTrashState()) {
    _sub = _repo
        .watch(const MediaListQuery(includeDeleted: true))
        .listen((items) => emit(MediaTrashState(items: items, loading: false)));
  }

  final MediaRepository _repo;
  final ImageStorage _images;
  late final StreamSubscription<List<MediaEntry>> _sub;

  Future<void> restore(String id) => _repo.restore(id);

  /// Hard-delete: удаляет строку И файлы картинок (§7.3) — image-id берём из
  /// уже загруженной записи (1:N), файлы чистим ПОСЛЕ коммита удаления.
  Future<void> purge(String id) async {
    final imageIds = state.items
        .where((e) => e.id == id)
        .expand((e) => e.images.map((i) => i.id))
        .toList();
    await _repo.purge(id);
    await _deleteFiles(imageIds);
  }

  Future<void> purgeAll() async {
    final imageIds =
        state.items.expand((e) => e.images.map((i) => i.id)).toList();
    await _repo.purgeAllTrashed();
    await _deleteFiles(imageIds);
  }

  Future<void> _deleteFiles(List<String> imageIds) async {
    for (final imageId in imageIds) {
      await _images.deleteFiles(imageId);
    }
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/tag.dart';
import '../../../../core/catalog/tag_repository.dart';

class TagManagerState extends Equatable {
  const TagManagerState({this.tags = const [], this.loading = true});

  final List<TagWithCount> tags;
  final bool loading;

  bool get isEmpty => !loading && tags.isEmpty;

  @override
  List<Object?> get props => [tags, loading];
}

/// Управление справочником тегов (экран 05): реактивный список со счётчиками
/// + операции переименование/цвет/слияние/удаление/создание. Список
/// пере-эмитит сам через стрим репозитория.
class TagManagerCubit extends Cubit<TagManagerState> {
  TagManagerCubit(this._repo) : super(const TagManagerState()) {
    _sub = _repo.watchAllWithCounts().listen(
          (tags) => emit(TagManagerState(tags: tags, loading: false)),
        );
  }

  final TagRepository _repo;
  late final StreamSubscription<List<TagWithCount>> _sub;

  Future<void> create(String name) async {
    if (name.trim().isEmpty) return;
    await _repo.ensure(name);
  }

  Future<void> rename(String id, String name) async {
    if (name.trim().isEmpty) return;
    await _repo.rename(id, name);
  }

  Future<void> recolor(String id, String? color) => _repo.recolor(id, color);

  Future<void> delete(String id) => _repo.delete(id);

  Future<void> merge(String sourceId, String targetId) =>
      _repo.merge(sourceId, targetId);

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

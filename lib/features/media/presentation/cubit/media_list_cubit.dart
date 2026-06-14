import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_query.dart';
import '../../domain/media_repository.dart';

class MediaListState extends Equatable {
  const MediaListState({this.items = const [], this.loading = true});

  final List<MediaEntry> items;
  final bool loading;

  bool get isEmpty => !loading && items.isEmpty;

  /// Полка «Жду новые серии» = пауза + причина «жду серии».
  List<MediaEntry> get waiting => items
      .where((e) =>
          e.status == WatchStatus.paused &&
          e.unfinishedReason == UnfinishedReason.waitingEpisodes)
      .toList();

  List<MediaEntry> get watchingNow =>
      items.where((e) => e.status == WatchStatus.watching).toList();

  @override
  List<Object?> get props => [items, loading];
}

/// Реактивный список карточек: подписан на репозиторий, пере-эмитит при
/// любом изменении данных. Подписка закрывается в [close].
class MediaListCubit extends Cubit<MediaListState> {
  MediaListCubit(this._repo) : super(const MediaListState()) {
    _sub = _repo.watch(const MediaListQuery()).listen(
          (items) => emit(MediaListState(items: items, loading: false)),
        );
  }

  final MediaRepository _repo;
  late final StreamSubscription<List<MediaEntry>> _sub;

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/media_entry.dart';
import '../../domain/media_query.dart';
import '../../domain/media_repository.dart';

/// Снимок всех живых карточек (без фильтра/поиска) + флаг загрузки.
class LiveCardsState extends Equatable {
  const LiveCardsState({this.entries = const [], this.loading = true});

  final List<MediaEntry> entries;
  final bool loading;

  @override
  List<Object?> get props => [entries, loading];
}

/// Реактивно следит за ВСЕМИ живыми карточками (пустой `MediaListQuery` =
/// без фильтров). Общий для экранов, которым нужен полный набор, не зависящий
/// от фильтра Главной (Календарь, Картотека).
class LiveCardsCubit extends Cubit<LiveCardsState> {
  LiveCardsCubit(this._repo) : super(const LiveCardsState()) {
    _sub = _repo.watch(const MediaListQuery()).listen(
          (items) => emit(LiveCardsState(entries: items, loading: false)),
        );
  }

  final MediaRepository _repo;
  StreamSubscription<List<MediaEntry>>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

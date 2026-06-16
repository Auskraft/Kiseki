import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/media_entry.dart';
import '../../domain/media_query.dart';
import '../../domain/media_repository.dart';

/// Состояние календаря: все живые карточки (без фильтра Главной) + флаг загрузки.
class CalendarState extends Equatable {
  const CalendarState({this.entries = const [], this.loading = true});

  final List<MediaEntry> entries;
  final bool loading;

  @override
  List<Object?> get props => [entries, loading];
}

/// Реактивно следит за ВСЕМИ живыми карточками (пустой `MediaListQuery` =
/// без фильтров/поиска) — календарю нужен полный набор, не отфильтрованный
/// список Главной. Собственный кубит, чтобы не зависеть от `MediaListCubit`.
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(this._repo) : super(const CalendarState()) {
    _sub = _repo.watch(const MediaListQuery()).listen(
          (items) => emit(CalendarState(entries: items, loading: false)),
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

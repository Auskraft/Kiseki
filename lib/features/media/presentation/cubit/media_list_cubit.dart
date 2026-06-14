import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/unfinished_reason.dart';
import '../../../../core/catalog/watch_status.dart';
import '../../domain/media_entry.dart';
import '../../domain/media_query.dart';
import '../../domain/media_repository.dart';

enum ViewMode { grid, list }

class MediaListState extends Equatable {
  const MediaListState({
    this.items = const [],
    this.loading = true,
    this.query = const MediaListQuery(),
    this.viewMode = ViewMode.grid,
  });

  final List<MediaEntry> items;
  final bool loading;
  final MediaListQuery query;
  final ViewMode viewMode;

  /// Картотека пуста (онбординг) — нет данных И нет активного поиска/фильтра.
  bool get isEmpty => !loading && items.isEmpty && !hasSearchOrFilter;

  /// Поиск/фильтр дал пустой результат (показываем «ничего не найдено»).
  bool get noResults => !loading && items.isEmpty && hasSearchOrFilter;

  bool get hasSearchOrFilter => query.hasSearch || query.hasFilters;

  /// Полки показываем только в режиме просмотра (без поиска/фильтра).
  List<MediaEntry> get waiting => hasSearchOrFilter
      ? const []
      : items
          .where((e) =>
              e.status == WatchStatus.paused &&
              e.unfinishedReason == UnfinishedReason.waitingEpisodes)
          .toList();

  List<MediaEntry> get watchingNow => hasSearchOrFilter
      ? const []
      : items.where((e) => e.status == WatchStatus.watching).toList();

  MediaListState copyWith({
    List<MediaEntry>? items,
    bool? loading,
    MediaListQuery? query,
    ViewMode? viewMode,
  }) {
    return MediaListState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      query: query ?? this.query,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [items, loading, query, viewMode];
}

/// Реактивный список карточек. Запрос (поиск/фильтр/сортировка) сменяемый —
/// при смене пере-подписываемся на новый `watch` (старая подписка снимается,
/// чтобы не было двойных стримов). Подписка закрывается в [close].
class MediaListCubit extends Cubit<MediaListState> {
  MediaListCubit(this._repo) : super(const MediaListState()) {
    _resubscribe(const MediaListQuery());
  }

  final MediaRepository _repo;
  StreamSubscription<List<MediaEntry>>? _sub;

  void _resubscribe(MediaListQuery query) {
    _sub?.cancel();
    // Запрос обновляем сразу (фильтр-лист/полки реагируют), элементы — по
    // приходу из стрима (старые держим до прихода новых — без мигания).
    emit(state.copyWith(query: query));
    _sub = _repo.watch(query).listen(
          (items) => emit(state.copyWith(items: items, loading: false)),
        );
  }

  void setQuery(MediaListQuery query) => _resubscribe(query);

  void setSearch(String text) {
    final trimmed = text.trim();
    _resubscribe(
      state.query.copyWith(text: () => trimmed.isEmpty ? null : trimmed),
    );
  }

  /// Сбрасывает поиск и фильтры, сохраняя текущую сортировку.
  void resetFilters() => _resubscribe(MediaListQuery(
        sortField: state.query.sortField,
        sortDirection: state.query.sortDirection,
      ));

  void setViewMode(ViewMode mode) => emit(state.copyWith(viewMode: mode));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

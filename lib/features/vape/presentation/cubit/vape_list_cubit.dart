import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/vape_entry.dart';
import '../../domain/vape_repository.dart';

class VapeListState extends Equatable {
  const VapeListState({this.entries = const [], this.loading = true});

  final List<VapeEntry> entries;
  final bool loading;

  @override
  List<Object?> get props => [entries, loading];
}

/// Реактивный список всех живых жидкостей (для вкладки Картотека).
class VapeListCubit extends Cubit<VapeListState> {
  VapeListCubit(this._repo) : super(const VapeListState()) {
    _sub = _repo.watch().listen(
          (e) => emit(VapeListState(entries: e, loading: false)),
        );
  }

  final VapeRepository _repo;
  StreamSubscription<List<VapeEntry>>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

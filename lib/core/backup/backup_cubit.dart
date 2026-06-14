import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'backup_archive.dart';
import 'yandex_disk_service.dart';

class BackupState extends Equatable {
  const BackupState({
    this.linked = false,
    this.account,
    this.busy = false,
    this.lastBackup,
    this.error,
    this.justBackedUp = false,
  });

  /// Аккаунт Я.Диска привязан (есть токен).
  final bool linked;
  final String? account;

  /// Идёт подключение или загрузка бэкапа.
  final bool busy;

  final DateTime? lastBackup;

  /// Транзиентное сообщение об ошибке.
  final String? error;

  /// Поднимается после успешного бэкапа (для snackbar).
  final bool justBackedUp;

  BackupState copyWith({
    bool? linked,
    String? account,
    bool? busy,
    DateTime? lastBackup,
    String? error,
    bool? justBackedUp,
  }) =>
      BackupState(
        linked: linked ?? this.linked,
        account: account ?? this.account,
        busy: busy ?? this.busy,
        lastBackup: lastBackup ?? this.lastBackup,
        error: error,
        justBackedUp: justBackedUp ?? false,
      );

  @override
  List<Object?> get props =>
      [linked, account, busy, lastBackup, error, justBackedUp];
}

/// Состояние бэкапа на Я.Диск для экрана настроек: подключение аккаунта,
/// ручной бэкап (упаковка `.kiseki` → загрузка), отвязка.
class BackupCubit extends Cubit<BackupState> {
  BackupCubit(this._disk, this._archive) : super(const BackupState()) {
    _load();
  }

  final YandexDiskService _disk;
  final BackupArchive _archive;

  Future<void> _load() async {
    if (!_disk.isLinked) {
      emit(const BackupState());
      return;
    }
    final name = await _disk.getDisplayName();
    emit(BackupState(
      linked: true,
      account: name,
      lastBackup: _disk.lastBackupTime(),
    ));
  }

  Future<void> connect() async {
    emit(state.copyWith(busy: true));
    try {
      final ok = await _disk.loginWithBrowser();
      if (ok) {
        final name = await _disk.getDisplayName(forceRefresh: true);
        emit(BackupState(linked: true, account: name));
      } else {
        emit(state.copyWith(busy: false));
      }
    } catch (_) {
      emit(state.copyWith(busy: false, error: 'Не удалось подключить Я.Диск'));
    }
  }

  Future<void> disconnect() async {
    await _disk.logout();
    emit(const BackupState());
  }

  Future<void> backupNow() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      final bytes = await _archive.pack();
      await _disk.uploadBackup(bytes);
      emit(state.copyWith(
        busy: false,
        lastBackup: _disk.lastBackupTime(),
        justBackedUp: true,
      ));
    } catch (_) {
      emit(state.copyWith(busy: false, error: 'Не удалось сделать бэкап'));
    }
  }
}

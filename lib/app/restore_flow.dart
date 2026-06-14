import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

import '../core/backup/backup_archive.dart';
import '../core/backup/yandex_disk_service.dart';
import '../core/database/app_database.dart';
import '../core/images/media_paths.dart';
import '../core/ui/restart_widget.dart';
import 'di/injector.dart';

/// Replace-all восстановление (TECH_DESIGN §8.1): скачать копию с Я.Диска →
/// распаковать и проверить → safety-снимок текущей БД → подменить файл БД и
/// картинки → пересобрать DI и перезапустить дерево с чистого корня.
///
/// Бросает [BackupException] при сетевой/форматной проблеме ДО подмены — то
/// есть до этого момента состояние приложения не меняется.
Future<void> runRestore(BuildContext context) async {
  // Захватываем контроллер ДО async-гэпов (дальше context не используем).
  final restarter = RestartWidget.of(context);
  final disk = getIt<YandexDiskService>();
  final archive = getIt<BackupArchive>();

  final bytes = await disk.downloadBackup();
  if (bytes == null) {
    throw const BackupException('На Диске нет резервной копии');
  }
  final unpacked = await archive.unpack(bytes);

  await restarter.reloadWith(() => _swap(unpacked));
}

/// Полный сброс при неустранимом повреждении БД (экран восстановления):
/// удалить файл БД (+WAL/SHM) и картинки, пересобрать DI и перезапустить
/// дерево — Drift откроет/создаст чистую БД (`onCreate`). Деструктивно.
Future<void> runWipeAndRestart(BuildContext context) async {
  final restarter = RestartWidget.of(context);
  await restarter.reloadWith(() async {
    final root = getIt<MediaPaths>().root;
    await getIt<AppDatabase>().close();
    for (final ext in const ['', '-wal', '-shm']) {
      final f = File(p.join(root.path, '$kDbFileName$ext'));
      if (f.existsSync()) await f.delete();
    }
    final media = Directory(p.join(root.path, 'media'));
    if (media.existsSync()) await media.delete(recursive: true);
    await getIt.reset();
    await configureDependencies();
  });
}

Future<void> _swap(UnpackedBackup unpacked) async {
  final root = getIt<MediaPaths>().root;
  final dbFile = File(p.join(root.path, kDbFileName));
  final safety = File(p.join(root.path, 'kiseki_safety.sqlite'));

  // Safety-снимок текущей БД (на случай сбоя) — пока она ещё открыта.
  try {
    await getIt<AppDatabase>().snapshotInto(safety.path);
  } catch (_) {
    // Не критично — продолжаем восстановление.
  }

  await getIt<AppDatabase>().close();
  await unpacked.applyTo(dbFile: dbFile, mediaRoot: root);
  await unpacked.dispose();

  await getIt.reset();
  await configureDependencies();

  // FTS-индекс после restore (§4.4/ADR-10): снимок несёт FTS verbatim, но
  // пересборка страхует от расхождения схемы FTS снимка с текущим бинарём.
  try {
    await getIt<AppDatabase>().rebuildFts();
  } catch (_) {/* поиск восстановится со следующей правки */}

  // Snapshot-безопасности больше не нужен (restore удался) — убираем, чтобы он
  // не копился и не мешал VACUUM INTO следующего restore.
  if (safety.existsSync()) {
    try {
      safety.deleteSync();
    } catch (_) {/* не критично */}
  }
}

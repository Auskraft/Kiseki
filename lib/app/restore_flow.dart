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

Future<void> _swap(UnpackedBackup unpacked) async {
  final root = getIt<MediaPaths>().root;
  final dbFile = File(p.join(root.path, kDbFileName));

  // Safety-снимок текущей БД (на случай сбоя) — пока она ещё открыта.
  try {
    await getIt<AppDatabase>()
        .snapshotInto(p.join(root.path, 'kiseki_safety.sqlite'));
  } catch (_) {
    // Не критично — продолжаем восстановление.
  }

  await getIt<AppDatabase>().close();
  await unpacked.applyTo(dbFile: dbFile, mediaRoot: root);
  await unpacked.dispose();

  await getIt.reset();
  await configureDependencies();
}

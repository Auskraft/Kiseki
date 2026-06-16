import 'dart:io';

import 'package:drift/native.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/backup/backup_archive.dart';
import '../../core/backup/yandex_disk_service.dart';
import '../../core/catalog/tag_repository.dart';
import '../../core/catalog/tag_repository_impl.dart';
import '../../core/database/app_database.dart';
import '../../core/images/image_processor.dart';
import '../../core/images/image_storage.dart';
import '../../core/images/media_paths.dart';
import '../../features/media/data/media_repository_impl.dart';
import '../../features/media/domain/media_repository.dart';
import '../../features/vape/data/vape_repository_impl.dart';
import '../../features/vape/domain/vape_repository.dart';

/// Глобальный service-locator (ADR-13: get_it + ручной composition root).
final GetIt getIt = GetIt.instance;

/// Composition root. БД и сервисы — синглтоны (одна БД на приложение —
/// критично для инвалидации Drift-стримов). Bloc/cubit будут factory
/// (создаются через BlocProvider на экране) в UI-итерации.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // БД лежит в каталоге приложения рядом с media/ (§7.2) — явный путь нужен
  // для restore (подмена файла). NativeDatabase (не background-isolate) —
  // детерминированное закрытие перед подменой файла.
  final supportDir = await getApplicationSupportDirectory();
  final db = AppDatabase(NativeDatabase(File(p.join(supportDir.path, kDbFileName))));
  getIt.registerSingleton<AppDatabase>(db);

  getIt.registerSingleton<MediaPaths>(MediaPaths(supportDir));
  getIt.registerSingleton<ImageProcessor>(const FlutterImageProcessor());
  getIt.registerLazySingleton<ImageStorage>(
    () => ImageStorage(getIt<MediaPaths>(), getIt<ImageProcessor>()),
  );

  getIt.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<VapeRepository>(
    () => VapeRepositoryImpl(getIt<AppDatabase>()),
  );

  // Бэкап на Я.Диск (Этап F).
  getIt.registerLazySingleton<YandexDiskService>(
    () => YandexDiskService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<BackupArchive>(
    () => BackupArchive(getIt<AppDatabase>(), getIt<MediaPaths>()),
  );
}

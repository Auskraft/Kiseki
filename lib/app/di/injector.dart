import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/catalog/tag_repository.dart';
import '../../core/catalog/tag_repository_impl.dart';
import '../../core/database/app_database.dart';
import '../../core/images/image_processor.dart';
import '../../core/images/image_storage.dart';
import '../../core/images/media_paths.dart';
import '../../features/media/data/media_repository_impl.dart';
import '../../features/media/domain/media_repository.dart';

/// Глобальный service-locator (ADR-13: get_it + ручной composition root).
final GetIt getIt = GetIt.instance;

/// Composition root. БД и сервисы — синглтоны (одна БД на приложение —
/// критично для инвалидации Drift-стримов). Bloc/cubit будут factory
/// (создаются через BlocProvider на экране) в UI-итерации.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  final db = AppDatabase.open();
  getIt.registerSingleton<AppDatabase>(db);

  final supportDir = await getApplicationSupportDirectory();
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
}

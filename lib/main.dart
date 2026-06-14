import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/di/injector.dart';
import 'core/catalog/tag_repository.dart';
import 'core/images/image_storage.dart';
import 'core/theme/app_dimens.dart';
import 'core/ui/restart_widget.dart';
import 'core/theme/kiseki_themes.dart';
import 'core/theme/theme_cubit.dart';
import 'dev/demo_seed.dart';
import 'features/media/domain/media_query.dart';
import 'features/media/domain/media_repository.dart';
import 'features/media/presentation/cubit/media_list_cubit.dart';
import 'features/media/presentation/pages/main_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // DEV: засеять демо-данные, если картотека пуста (только в debug).
  if (kDebugMode) {
    final repo = getIt<MediaRepository>();
    final existing = await repo.watch(const MediaListQuery()).first;
    if (existing.isEmpty) {
      await seedDemoData(repo, getIt<TagRepository>());
    }
  }

  // Чистка файлов-сирот картинок (нет ссылки в БД) — фоном, не блокирует старт.
  unawaited(() async {
    try {
      await getIt<ImageStorage>()
          .sweepOrphans(await getIt<MediaRepository>().allImageIds());
    } catch (_) {/* не критично */}
  }());

  runApp(const RestartWidget(child: KisekiApp()));
}

class KisekiApp extends StatelessWidget {
  const KisekiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(getIt<SharedPreferences>())),
        BlocProvider(create: (_) => MediaListCubit(getIt<MediaRepository>())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ru'),
            debugShowCheckedModeBanner: false,
            theme: buildKisekiTheme(themeState.themeId, Brightness.light),
            darkTheme: buildKisekiTheme(themeState.themeId, Brightness.dark),
            themeMode: themeState.themeMode,
            themeAnimationDuration: AppDurations.themeMorph,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

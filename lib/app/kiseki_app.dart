import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_dimens.dart';
import '../core/theme/kiseki_themes.dart';
import '../core/theme/theme_cubit.dart';
import '../features/media/domain/media_repository.dart';
import '../features/media/presentation/cubit/media_list_cubit.dart';
import '../l10n/app_localizations.dart';
import 'di/injector.dart';
import 'router/app_router.dart';

/// Корень приложения после успешной проверки БД ([AppBootstrap]).
/// Прикладные блоки провайдятся выше `MaterialApp.router` → доступны всем
/// маршрутам и переживают навигацию.
class KisekiApp extends StatefulWidget {
  const KisekiApp({super.key});

  @override
  State<KisekiApp> createState() => _KisekiAppState();
}

class _KisekiAppState extends State<KisekiApp> {
  // Один экземпляр на монтирование дерева: переживает пересборку темы и
  // сбрасывается на старт при Replace-all восстановлении (RestartWidget
  // перемонтирует дерево с новым ключом → новый State → новый роутер).
  final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(getIt<SharedPreferences>())),
        BlocProvider(create: (_) => MediaListCubit(getIt<MediaRepository>())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ru'),
            debugShowCheckedModeBanner: false,
            theme: buildKisekiTheme(themeState.themeId, Brightness.light),
            darkTheme: buildKisekiTheme(themeState.themeId, Brightness.dark),
            themeMode: themeState.themeMode,
            themeAnimationDuration: AppDurations.themeMorph,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

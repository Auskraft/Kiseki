import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/app/router/app_router.dart';
import 'package:kiseki/core/catalog/tag_repository.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/nav/fab_style.dart';
import 'package:kiseki/core/nav/menu_icons.dart';
import 'package:kiseki/core/nav/nav_style.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/core/theme/theme_cubit.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_repository.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_list_cubit.dart';
import 'package:kiseki/features/vape/data/vape_repository_impl.dart';
import 'package:kiseki/features/vape/domain/vape_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Интеграция A4: реальная связка приложения — прикладные блоки провайдятся
/// ВЫШЕ `MaterialApp.router`, а экраны строит go_router НИЖЕ него. Проверяем,
/// что построенный роутером MainScreen (initialLocation `/`) достучался до
/// `MediaListCubit` через границу роутера. Сам переход на карточку по UUID и
/// возврат назад покрыты в `media_detail_page_test` (push/pop под router).
void main() {
  late AppDatabase db;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() async {
    // classic нав-бар + FAB без градиента — обе бесконечные анимации выключены,
    // иначе pumpAndSettle не дождётся (капсула/дышащий градиент).
    SharedPreferences.setMockInitialValues(
        {'nav_bar_style': 'classic', 'fab_gradient_anim': false});
    db = AppDatabase(NativeDatabase.memory());
    final repo = MediaRepositoryImpl(db);
    getIt.registerSingleton<MediaRepository>(repo);
    getIt.registerSingleton<VapeRepository>(VapeRepositoryImpl(db));
    getIt.registerSingleton<TagRepository>(TagRepositoryImpl(db));
    await repo.create(const MediaDraft(
      title: 'Сквозь снег',
      mediaType: MediaType.movie,
      format: MediaFormat.single,
    ));
  });
  tearDown(() async {
    await getIt.reset();
    await db.close();
  });

  testWidgets('провайдеры над MaterialApp.router доступны экранам go_router',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    // Блоки создаём вне дерева и закрываем через addTearDown (до db.close) —
    // Drift-подписки уходят чисто, без «pending timer».
    final themeCubit = ThemeCubit(prefs);
    addTearDown(themeCubit.close);
    final listCubit = MediaListCubit(getIt<MediaRepository>());
    addTearDown(listCubit.close);
    final navCubit = NavStyleCubit(prefs);
    addTearDown(navCubit.close);
    final iconsCubit = MenuIconsCubit(prefs);
    addTearDown(iconsCubit.close);
    final fabCubit = FabStyleCubit(prefs);
    addTearDown(fabCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: themeCubit),
          BlocProvider.value(value: listCubit),
          BlocProvider.value(value: navCubit),
          BlocProvider.value(value: iconsCubit),
          BlocProvider.value(value: fabCubit),
        ],
        child: MaterialApp.router(
          theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
          routerConfig: createAppRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // MainScreen построен go_router'ом и достал MediaListCubit (провайдер выше
    // MaterialApp.router) → список отрисован.
    // «Главная» — и в шапке экрана, и подписью вкладки в нав-баре.
    expect(find.text('Главная'), findsWidgets);
    expect(find.text('Сквозь снег'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

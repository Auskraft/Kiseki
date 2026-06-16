import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/catalog/rating.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_list_cubit.dart';
import 'package:kiseki/features/media/presentation/pages/main_screen.dart';
import 'package:kiseki/features/vape/data/vape_repository_impl.dart';
import 'package:kiseki/features/vape/domain/vape_repository.dart';

void main() {
  setUpAll(() {
    // В тестах не ходим в сеть за шрифтами — используем фолбэк.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('MainScreen: пустое состояние, затем карточка', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = MediaRepositoryImpl(db);
    getIt.registerSingleton<VapeRepository>(VapeRepositoryImpl(db));
    addTearDown(getIt.reset);
    final cubit = MediaListCubit(repo);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
        home: BlocProvider.value(value: cubit, child: const MainScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Здесь пока пусто'), findsOneWidget);

    await repo.create(const MediaDraft(
      title: 'Тестовый фильм',
      mediaType: MediaType.movie,
      format: MediaFormat.single,
      status: WatchStatus.completed,
      rating: Rating(80),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Тестовый фильм'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

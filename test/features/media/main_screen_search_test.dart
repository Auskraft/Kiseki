import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_list_cubit.dart';
import 'package:kiseki/features/media/presentation/pages/main_screen.dart';
import 'package:kiseki/features/media/presentation/widgets/media_list_tile.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('поиск фильтрует и переключение на список показывает плитки',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = MediaRepositoryImpl(db);
    await repo.create(const MediaDraft(
        title: 'Дюна', mediaType: MediaType.movie, format: MediaFormat.single));
    await repo.create(const MediaDraft(
        title: 'Матрица',
        mediaType: MediaType.movie,
        format: MediaFormat.single));

    final cubit = MediaListCubit(repo);
    addTearDown(cubit.close);

    await tester.pumpWidget(MaterialApp(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      home: BlocProvider.value(value: cubit, child: const MainScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Дюна'), findsOneWidget);
    expect(find.text('Матрица'), findsOneWidget);

    // Поиск (с дебаунсом) сужает список.
    await tester.enterText(find.byType(TextField), 'дюна');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Дюна'), findsOneWidget);
    expect(find.text('Матрица'), findsNothing);
    expect(find.text('Найдено 1'), findsOneWidget);

    // Переключение на список-вид рисует MediaListTile.
    await tester.tap(find.byIcon(Icons.view_agenda_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(MediaListTile), findsOneWidget);
  });
}

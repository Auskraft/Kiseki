import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_repository.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/pages/kartoteka_page.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    getIt.registerSingleton<MediaRepository>(MediaRepositoryImpl(db));
  });
  tearDown(() async {
    await getIt.reset();
    await db.close();
  });

  Widget host() => MaterialApp(
        theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
        home: const KartotekaPage(),
      );

  // Спиннер загрузки бесконечен → pump(Duration), не pumpAndSettle.
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('картотека: список, фильтр по статусу, выпадашка домена',
      (tester) async {
    final repo = getIt<MediaRepository>();
    await repo.create(const MediaDraft(
      title: 'Фильм А',
      mediaType: MediaType.movie,
      format: MediaFormat.single,
      status: WatchStatus.completed,
    ));
    await repo.create(const MediaDraft(
      title: 'План Б',
      mediaType: MediaType.movie,
      format: MediaFormat.single,
      status: WatchStatus.plan,
    ));

    await tester.pumpWidget(host());
    await settle(tester);

    // Список показывает обе карточки.
    expect(find.text('Фильм А'), findsOneWidget);
    expect(find.text('План Б'), findsOneWidget);

    // Фильтр «Просмотрено» (первый — чип-фильтр) оставляет только completed.
    await tester.ensureVisible(find.text('Просмотрено').first);
    await tester.pump();
    await tester.tap(find.text('Просмотрено').first);
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Фильм А'), findsOneWidget);
    expect(find.text('План Б'), findsNothing);

    // Выпадашка домена → «Чтение» = заглушка.
    await tester.tap(find.text('Просмотр'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
    await tester.tap(find.text('Чтение').last);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
    expect(find.text('Чтение — скоро'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

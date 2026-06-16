import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/catalog/catalog_date.dart';
import 'package:kiseki/core/catalog/date_precision.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_repository.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/pages/calendar_page.dart';

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
        home: const CalendarPage(),
      );

  // Спиннер загрузки — бесконечная анимация, поэтому pump(Duration), не
  // pumpAndSettle. Несколько кадров дают Drift-стриму кубита эмитнуть снимок.
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('календарь: помесячный таймлайн, Гант и выпадашка домена',
      (tester) async {
    // Даты — в UTC (как строит normalizeCatalogDate в реальном вводе), иначе в
    // +TZ месяц съезжает при round-trip.
    await getIt<MediaRepository>().create(MediaDraft(
      title: 'Сквозь снег',
      mediaType: MediaType.movie,
      format: MediaFormat.episodic,
      status: WatchStatus.completed,
      startedAt: CatalogDate(DateTime.utc(2024, 3), DatePrecision.month),
      finishedAt: CatalogDate(DateTime.utc(2024, 6), DatePrecision.month),
    ));

    // Высокая поверхность — чтобы все месяцы периода построились (ListView ленив).
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await settle(tester);

    // Период март..июнь — крайние месяцы на месте, чип в каждом из 4 месяцев.
    expect(find.text('Март 2024'), findsOneWidget);
    expect(find.text('Июнь 2024'), findsOneWidget);
    expect(find.text('Сквозь снег'), findsNWidgets(4));

    // Переключение на Гант — карточка одной строкой.
    await tester.tap(find.text('Гант'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Сквозь снег'), findsOneWidget);

    // Выпадашка домена → «Чтение» = заглушка. onSelected у PopupMenuButton
    // срабатывает после анимации закрытия меню — прокачиваем кадры с запасом.
    await tester.tap(find.text('Просмотр'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
    await tester.tap(find.text('Чтение').last);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
    expect(find.text('Чтение — скоро'), findsOneWidget);

    // Размонтируем — снять подписку кубита до закрытия БД.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

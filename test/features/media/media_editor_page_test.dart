import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/catalog/tag_repository.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/images/image_processor.dart';
import 'package:kiseki/core/images/image_storage.dart';
import 'package:kiseki/core/images/media_paths.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/domain/media_entry.dart';
import 'package:kiseki/features/media/domain/media_query.dart';
import 'package:kiseki/features/media/domain/media_repository.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/presentation/pages/media_editor_page.dart';

void main() {
  late AppDatabase db;
  late Directory tmpRoot;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tmpRoot = Directory.systemTemp.createTempSync('kiseki_editor_pg_');
    getIt.registerSingleton<MediaRepository>(MediaRepositoryImpl(db));
    getIt.registerSingleton<TagRepository>(TagRepositoryImpl(db));
    getIt.registerSingleton<ImageStorage>(
        ImageStorage(MediaPaths(tmpRoot), const FlutterImageProcessor()));
  });
  tearDown(() async {
    await getIt.reset();
    await db.close();
    if (tmpRoot.existsSync()) tmpRoot.deleteSync(recursive: true);
  });

  // Хост с кнопкой, открывающей редактор как модальный боттом-шит.
  Widget host() => MaterialApp(
        theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => openMediaEditor(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

  testWidgets('шит раскрывается прогрессивно и создаёт карточку',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Новая карточка'), findsOneWidget);

    // Тип скрыт, пока не выбран формат; название — пока не выбран тип.
    expect(find.text('Тип'), findsNothing);
    expect(find.text('Название'), findsNothing);

    // Формат → появляется «Тип».
    await tester.tap(find.text('Одиночный'));
    await tester.pumpAndSettle();
    expect(find.text('Тип'), findsOneWidget);
    expect(find.text('Название'), findsNothing);

    // Вид → появляется «Название».
    await tester.tap(find.text('Фильм'));
    await tester.pumpAndSettle();
    expect(find.text('Название'), findsWidgets);

    // Вводим название и сохраняем иконкой-галочкой.
    await tester.enterText(find.byType(TextField).first, 'Тестовая карточка');
    await tester.pump();
    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pumpAndSettle();

    // Шит закрылся (justSaved → Navigator.pop).
    expect(find.text('Новая карточка'), findsNothing);

    // Дать Drift-стримам закрытого редактора отработать (иначе «pending timer»).
    await tester.pump(const Duration(seconds: 1));

    var items = <MediaEntry>[];
    await tester.runAsync(() async {
      items =
          await getIt<MediaRepository>().watch(const MediaListQuery()).first;
    });
    expect(items.map((e) => e.title), contains('Тестовая карточка'));
  });

  testWidgets('«Дополнительные параметры» раскрывают вложенный контент',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Одиночный'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Фильм'));
    await tester.pumpAndSettle();

    // Свёрнуто: вложенного контента ещё нет.
    expect(find.text('Дополнительные параметры'), findsOneWidget);
    expect(find.text('Даты просмотров'), findsNothing);

    // Тап по заголовку раскрывает секцию — контент появляется.
    await tester.ensureVisible(find.text('Дополнительные параметры'));
    await tester.tap(find.text('Дополнительные параметры'));
    await tester.pumpAndSettle();
    expect(find.text('Даты просмотров'), findsOneWidget);
    expect(find.text('Пересмотры'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('несохранённый ввод спрашивает подтверждение при закрытии',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Одиночный'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Фильм'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Черновик');
    await tester.pump();

    // Закрытие (свайп вниз / системный «назад») при несохранённом вводе →
    // PopScope перехватывает и показывает подтверждение.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Отменить создание?'), findsOneWidget);

    // «Продолжить» — остаёмся в редакторе, ввод на месте.
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Отменить создание?'), findsNothing);
    expect(find.text('Новая карточка'), findsOneWidget);

    // Размонтируем дерево и даём Drift-подписке тегов закрыться (иначе
    // «pending timer» — редактор остаётся смонтированным с активным watch).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}

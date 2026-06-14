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
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_entry.dart';
import 'package:kiseki/features/media/domain/media_query.dart';
import 'package:kiseki/features/media/domain/media_repository.dart';
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

  testWidgets('форма создаёт карточку и возвращается назад', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(ctx, MediaEditorPage.route()),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Новая карточка'), findsOneWidget);

    // Кнопка сохранения неактивна без названия — карточка не создаётся.
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Новая карточка'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Тестовая карточка');
    await tester.pump();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // Возврат на стартовый экран = justSaved (карточка успешно создана).
    expect(find.text('open'), findsOneWidget);
    expect(find.text('Новая карточка'), findsNothing);

    // Дать Drift-стримам закрытого редактора отработать (иначе «pending timer»).
    await tester.pump(const Duration(seconds: 1));

    var items = <MediaEntry>[];
    await tester.runAsync(() async {
      items = await getIt<MediaRepository>()
          .watch(const MediaListQuery())
          .first;
    });
    expect(items.map((e) => e.title), contains('Тестовая карточка'));
  });
}

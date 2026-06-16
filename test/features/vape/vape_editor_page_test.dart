import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/images/image_processor.dart';
import 'package:kiseki/core/images/image_storage.dart';
import 'package:kiseki/core/images/media_paths.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/vape/data/vape_repository_impl.dart';
import 'package:kiseki/features/vape/domain/vape_entry.dart';
import 'package:kiseki/features/vape/domain/vape_repository.dart';
import 'package:kiseki/features/vape/presentation/pages/vape_editor_page.dart';

void main() {
  late AppDatabase db;
  late Directory tmpRoot;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tmpRoot = Directory.systemTemp.createTempSync('kiseki_vape_ed_');
    getIt.registerSingleton<VapeRepository>(VapeRepositoryImpl(db));
    getIt.registerSingleton<ImageStorage>(
        ImageStorage(MediaPaths(tmpRoot), const FlutterImageProcessor()));
  });
  tearDown(() async {
    await getIt.reset();
    await db.close();
    if (tmpRoot.existsSync()) tmpRoot.deleteSync(recursive: true);
  });

  Widget host() => MaterialApp(
        theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => openVapeEditor(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

  testWidgets('редактор жидкости создаёт запись с обязательными полями',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Добавить жидкость'), findsOneWidget);

    // Тип → чипы крепости → «20». До ввода текста: нет фокуса (pumpAndSettle ок;
    // фокус текстового поля держит таймер курсора и вешает pumpAndSettle).
    await tester.tap(find.text('Солевой'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('20'));
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    // Бренд (0) + Название вкуса (1) — первые два видимых поля; вводим в конце.
    await tester.enterText(find.byType(TextField).at(0), 'BrandX');
    await tester.enterText(find.byType(TextField).at(1), 'Манго-лёд');
    await tester.pump();

    // Сохранение иконкой-галочкой (закрывает шит → поле уходит из фокуса).
    await tester.tap(find.byKey(const Key('vape-editor-save')));
    await tester.pumpAndSettle();
    expect(find.text('Добавить жидкость'), findsNothing); // шит закрылся

    // Слить таймеры закрытого шита; читать БД через runAsync (real-async Drift).
    await tester.pump(const Duration(seconds: 1));
    var list = <VapeEntry>[];
    await tester.runAsync(() async {
      list = await getIt<VapeRepository>().watch().first;
    });
    expect(list, hasLength(1));
    expect(list.first.title, 'Манго-лёд');
    expect(list.first.brand, 'BrandX');
    expect(list.first.nicotineStrength, '20');
  });
}

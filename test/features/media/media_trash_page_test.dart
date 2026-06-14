import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/images/image_processor.dart';
import 'package:kiseki/core/images/image_storage.dart';
import 'package:kiseki/core/images/media_paths.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_repository.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/pages/media_trash_page.dart';

void main() {
  late AppDatabase db;
  late Directory tmpRoot;
  late String entryId;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final repo = MediaRepositoryImpl(db);
    getIt.registerSingleton<MediaRepository>(repo);
    tmpRoot = Directory.systemTemp.createTempSync('kiseki_trash_pg_');
    getIt.registerSingleton<ImageStorage>(
        ImageStorage(MediaPaths(tmpRoot), const FlutterImageProcessor()));
    entryId = await repo.create(const MediaDraft(
      title: 'Удалённый фильм',
      mediaType: MediaType.movie,
      format: MediaFormat.single,
    ));
    await repo.softDelete(entryId);
  });
  tearDown(() async {
    await getIt.reset();
    await db.close();
    if (tmpRoot.existsSync()) tmpRoot.deleteSync(recursive: true);
  });

  testWidgets('корзина показывает запись и восстанавливает её', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/trash'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/trash',
          builder: (context, state) => const MediaTrashPage(),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      routerConfig: router,
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Удалённый фильм'), findsOneWidget);
    expect(find.text('Восстановить'), findsOneWidget);

    // Восстановление убирает карточку из корзины (реактивно) → пустое состояние.
    await tester.tap(find.text('Восстановить'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Корзина пуста'), findsOneWidget);

    // Назад + flush Drift-стримов закрытого экрана.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await tester.runAsync(() async {
      final e = await getIt<MediaRepository>().findById(entryId);
      expect(e!.isInTrash, isFalse);
    });
  });
}

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/catalog/tag_repository.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/presentation/pages/tags_page.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final repo = TagRepositoryImpl(db);
    getIt.registerSingleton<TagRepository>(repo);
    await repo.ensure('Драма');
  });
  tearDown(() async {
    await getIt.reset();
    await db.close();
  });

  testWidgets('экран тегов показывает тег и создаёт новый', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/tags'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/tags',
          builder: (context, state) => const TagsPage(),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      routerConfig: router,
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Драма'), findsOneWidget);

    // Создание нового тега через диалог.
    await tester.tap(find.widgetWithText(FilledButton, 'Новый тег'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Криминал');
    await tester.tap(find.text('Создать'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Криминал'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
  });
}

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/catalog/tag_repository.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_entry.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_repository.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/pages/media_detail_page.dart';

void main() {
  late AppDatabase db;
  late String entryId;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final repo = MediaRepositoryImpl(db);
    getIt.registerSingleton<MediaRepository>(repo);
    getIt.registerSingleton<TagRepository>(TagRepositoryImpl(db));
    entryId = await repo.create(const MediaDraft(
      title: 'Во все тяжкие',
      mediaType: MediaType.series,
      format: MediaFormat.episodic,
      status: WatchStatus.completed,
    ));
  });
  tearDown(() async {
    await getIt.reset();
    await db.close();
  });

  testWidgets('деталь рендерит карточку и переключает избранное',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/detail'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) => MediaDetailPage(entryId: entryId),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      routerConfig: router,
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Во все тяжкие'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    // Переключение избранного должно реактивно сменить иконку (watchById).
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Назад + flush Drift-стримов закрытого экрана.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    MediaEntry? e;
    await tester.runAsync(() async {
      e = await getIt<MediaRepository>().findById(entryId);
    });
    expect(e!.isFavorite, isTrue);
  });
}

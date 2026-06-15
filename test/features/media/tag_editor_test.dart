import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/core/catalog/tag.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/features/media/presentation/widgets/editor/tag_editor.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('чипы — только используемые теги; ввод даёт подсказку-жанр',
      (tester) async {
    String? created;
    await tester.pumpWidget(MaterialApp(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      home: Scaffold(
        body: TagEditor(
          allTags: const [
            TagWithCount(Tag(id: 'd', name: 'Драма'), 5),
            TagWithCount(Tag(id: 'k', name: 'Криминал'), 2),
            TagWithCount(Tag(id: 'b', name: 'Боевик'), 0),
          ],
          selectedIds: const {},
          onToggle: (_) {},
          onCreate: (n) => created = n,
        ),
      ),
    ));

    // Популярные чипы — только теги с живыми карточками; неиспользованный скрыт.
    expect(find.text('Драма'), findsOneWidget);
    expect(find.text('Криминал'), findsOneWidget);
    expect(find.text('Боевик'), findsNothing);

    // Ввод показывает подсказку-жанр из словаря (которого ещё нет в тегах).
    await tester.enterText(find.byType(TextField), 'Коме');
    await tester.pump();
    expect(find.text('Комедия'), findsOneWidget);

    await tester.tap(find.text('Комедия'));
    await tester.pump();
    expect(created, 'Комедия');

    // Снять таймер курсора TextField перед концом теста.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}

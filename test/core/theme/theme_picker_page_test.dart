import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/core/theme/theme_cubit.dart';
import 'package:kiseki/core/theme/theme_picker_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('пикер тем: тап по карточке меняет тему в кубите', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(prefs);
    addTearDown(themeCubit.close);

    await tester.pumpWidget(MaterialApp(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      home:
          BlocProvider.value(value: themeCubit, child: const ThemePickerPage()),
    ));
    await tester.pumpAndSettle();

    expect(themeCubit.state.themeId, KisekiThemeId.base);
    // «Сакура» — вторая карточка (верхний ряд, всегда построена).
    await tester.tap(find.text('Сакура'));
    await tester.pump();
    expect(themeCubit.state.themeId, KisekiThemeId.sakura);
  });
}

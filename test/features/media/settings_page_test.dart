import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/core/theme/kiseki_theme_id.dart';
import 'package:kiseki/core/theme/kiseki_themes.dart';
import 'package:kiseki/core/theme/theme_cubit.dart';
import 'package:kiseki/features/media/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('настройки рендерятся и меняют тему', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themeCubit = ThemeCubit(prefs);
    addTearDown(themeCubit.close);

    await tester.pumpWidget(MaterialApp(
      theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
      home: BlocProvider.value(value: themeCubit, child: const SettingsPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Сделать бэкап'), findsOneWidget);

    // Смена темы свотчем отражается в ThemeCubit.
    expect(themeCubit.state.themeId, KisekiThemeId.base);
    await tester.tap(find.text('Сакура'));
    await tester.pump();
    expect(themeCubit.state.themeId, KisekiThemeId.sakura);
  });
}

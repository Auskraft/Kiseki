import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiseki/app/bootstrap.dart';
import 'package:kiseki/app/di/injector.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:path/path.dart' as p;

/// Проверяет гейт запуска: при повреждённой БД [AppBootstrap] показывает экран
/// восстановления вместо приложения (TECH_DESIGN §9). Здоровый путь (→ приложение)
/// покрыт `app_router_test`.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('повреждённая БД → экран восстановления', (tester) async {
    final dir = Directory.systemTemp.createTempSync('kiseki_boot_corrupt_');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });
    final f = File(p.join(dir.path, 'broken.sqlite'))
      ..writeAsBytesSync(List.filled(2048, 0x42));
    final db = AppDatabase(NativeDatabase(f));
    getIt.registerSingleton<AppDatabase>(db);
    addTearDown(() async {
      await getIt.reset();
      try {
        await db.close();
      } catch (_) {/* битая БД */}
    });

    await tester.pumpWidget(const AppBootstrap());
    // Прокручиваем кадры, пока quick_check (микротаски Drift) не завершится и
    // setState не сменит сплеш на экран восстановления. pump, не pumpAndSettle
    // (спиннер сплеша крутится бесконечно) и не runAsync (иначе google_fonts
    // реально полезет за шрифтом и упадёт при allowRuntimeFetching=false).
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('Не удалось открыть базу'), findsOneWidget);
    expect(find.text('Восстановить из бэкапа'), findsOneWidget);
  });
}

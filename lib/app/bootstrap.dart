import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/catalog/tag_repository.dart';
import '../core/database/app_database.dart';
import '../core/images/image_storage.dart';
import '../core/theme/kiseki_theme_id.dart';
import '../core/theme/kiseki_themes.dart';
import '../dev/demo_seed.dart';
import '../features/media/domain/media_query.dart';
import '../features/media/domain/media_repository.dart';
import 'db_recovery_screen.dart';
import 'di/injector.dart';
import 'kiseki_app.dart';

enum _Boot { checking, ready, corrupted }

/// Гейт запуска: проверяет целостность БД ДО входа в приложение (TECH_DESIGN
/// §9). Здоровая БД → [KisekiApp]; повреждённая → [DbRecoveryScreen]. Живёт под
/// RestartWidget, поэтому при Replace-all/«начать заново» дерево
/// перемонтируется → проверка прогоняется заново на новой БД.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  _Boot _status = _Boot.checking;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // try/catch и вокруг getIt<AppDatabase>(): если reconfigure после неудачного
    // restore не поднял БД/DI, не зависаем на сплеше — показываем восстановление.
    bool ok;
    try {
      ok = await getIt<AppDatabase>().checkIntegrity();
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      if (mounted) setState(() => _status = _Boot.corrupted);
      return;
    }
    // Здоровая БД: dev-сид (debug) + чистка файлов-сирот — здесь, а не в main(),
    // чтобы не трогать повреждённую БД и чтобы шаги повторялись после Replace-all
    // (дерево перемонтируется → новый AppBootstrap).
    if (kDebugMode) {
      try {
        final repo = getIt<MediaRepository>();
        final existing = await repo.watch(const MediaListQuery()).first;
        if (existing.isEmpty) {
          await seedDemoData(repo, getIt<TagRepository>());
        }
      } catch (_) {/* сид не критичен */}
    }
    unawaited(() async {
      try {
        await getIt<ImageStorage>()
            .sweepOrphans(await getIt<MediaRepository>().allImageIds());
      } catch (_) {/* не критично */}
    }());
    if (mounted) setState(() => _status = _Boot.ready);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _Boot.ready => const KisekiApp(),
      _Boot.checking => _wrap(const _Splash()),
      _Boot.corrupted => _wrap(const DbRecoveryScreen()),
    };
  }

  /// Сплеш и экран восстановления показываются ДО KisekiApp (своего
  /// MaterialApp ещё нет) — заворачиваем в минимальный MaterialApp с темой,
  /// чтобы работали токены и Navigator (боттомшит подтверждения сброса).
  Widget _wrap(Widget home) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildKisekiTheme(KisekiThemeId.base, Brightness.light),
        darkTheme: buildKisekiTheme(KisekiThemeId.base, Brightness.dark),
        home: home,
      );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

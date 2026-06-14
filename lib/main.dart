import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'app/di/injector.dart';
import 'core/ui/restart_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // AppBootstrap проверит целостность БД и решит: приложение или экран
  // восстановления. RestartWidget оборачивает всё — нужен для Replace-all
  // восстановления и «начать заново» (перемонтаж дерева с чистого корня).
  runApp(const RestartWidget(child: AppBootstrap()));
}

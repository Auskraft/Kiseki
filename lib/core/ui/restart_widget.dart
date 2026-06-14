import 'package:flutter/material.dart';

/// Оборачивает приложение и умеет «перезапустить» его — демонтировать дерево
/// (блоки/Drift-подписки уходят) и собрать заново. Нужно для Replace-all
/// восстановления: поднять свежие синглтоны и блоки на новой БД с чистого
/// корня (TECH_DESIGN §8.1).
class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static RestartController of(BuildContext context) =>
      context.findAncestorStateOfType<_RestartWidgetState>()!;

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

abstract class RestartController {
  /// Демонтирует дерево, выполняет [swap] (закрытие БД, подмена файлов,
  /// пересборка DI) и монтирует дерево заново.
  Future<void> reloadWith(Future<void> Function() swap);
}

class _RestartWidgetState extends State<RestartWidget>
    implements RestartController {
  Key _key = UniqueKey();
  bool _busy = false;

  @override
  Future<void> reloadWith(Future<void> Function() swap) async {
    setState(() => _busy = true);
    // Кадр на demount дерева — отменить .watch-подписки ДО закрытия БД.
    await Future<void>.delayed(const Duration(milliseconds: 60));
    try {
      await swap();
    } finally {
      // ВСЕГДА снимаем _busy и перемонтируем дерево с новым ключом — даже если
      // swap бросил на полпути. Иначе исключение оставляло приложение на вечном
      // спиннере с закрытой БД. На успехе → свежая (восстановленная) БД; на
      // сбое → AppBootstrap заново прогонит checkIntegrity и покажет экран
      // восстановления. Исключение swap после finally пробрасывается вызывающему.
      if (mounted) {
        setState(() {
          _busy = false;
          _key = UniqueKey();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../features/media/presentation/pages/main_screen.dart';
import '../../features/media/presentation/pages/settings_page.dart';
import 'capsule_nav_bar.dart';
import 'classic_nav_bar.dart';
import 'coming_soon_page.dart';
import 'floating_nav_bar.dart';
import 'menu_icons.dart';
import 'nav_style.dart';

/// Оболочка приложения: 4 вкладки (Главная/Календарь/Картотека/Настройки) в
/// ленивом `IndexedStack` + выбранный пользователем нав-бар снизу + свайп между
/// вкладками. FAB «Добавить» — только на Главной (медиа). Стиль бара берётся из
/// [NavStyleCubit] (провайдится над роутером).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  static const _swipeMinVelocity = 80.0;

  void _go(int i) {
    if (i != _index) setState(() => _index = i);
  }

  void _swipe(int dir) {
    final n = kNavDestinations.length;
    HapticFeedback.selectionClick();
    setState(() => _index = (_index + dir + n) % n);
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavStyleCubit>().state;
    final items = navItemsFor(context.watch<MenuIconsCubit>().state);
    final builders = <WidgetBuilder>[
      (_) => const MainScreen(),
      (_) => const ComingSoonPage(
            title: 'Календарь',
            icon: Icons.calendar_month_rounded,
          ),
      (_) => const ComingSoonPage(
            title: 'Картотека',
            icon: Icons.grid_view_rounded,
          ),
      (_) => const SettingsPage(embedded: true),
    ];

    return Scaffold(
      // Тело заходит под нав-бар (эффект стекла виден); нижний отступ контента
      // descendant'ы берут из MediaQuery.padding.bottom (= высота бара).
      extendBody: true,
      body: _ShellBody(index: _index, builders: builders),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoute.editor),
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            )
          : null,
      // Обёртка-свайп здесь, а не в каждом баре — листание для всех 3 стилей.
      bottomNavigationBar: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v <= -_swipeMinVelocity) {
            _swipe(1);
          } else if (v >= _swipeMinVelocity) {
            _swipe(-1);
          }
        },
        child: _navBar(nav, items),
      ),
    );
  }

  Widget _navBar(NavStyleState s, List<NavBarItem> items) {
    switch (s.style) {
      case NavBarStyle.classic:
        return ClassicNavBar(
          items: items,
          currentIndex: _index,
          onTap: _go,
          glass: s.glass,
          glassLevel: s.glassLevel,
        );
      case NavBarStyle.floating:
        return FloatingNavBar(
          items: items,
          currentIndex: _index,
          onTap: _go,
          glass: s.glass,
          glassLevel: s.glassLevel,
        );
      case NavBarStyle.capsule:
        return CapsuleNavBar(
          items: items,
          currentIndex: _index,
          onTap: _go,
          glass: s.glass,
          glassLevel: s.glassLevel,
          gradient: s.gradient,
        );
    }
  }
}

/// Ленивый `IndexedStack` с плавным проявлением активной вкладки. Невизуальные
/// вкладки строятся только при первом заходе (Настройки с их `BackupCubit` не
/// поднимаются, пока вкладку не открыли); состояние посещённых сохраняется.
class _ShellBody extends StatefulWidget {
  const _ShellBody({required this.index, required this.builders});

  final int index;
  final List<WidgetBuilder> builders;

  @override
  State<_ShellBody> createState() => _ShellBodyState();
}

class _ShellBodyState extends State<_ShellBody>
    with SingleTickerProviderStateMixin {
  final _built = <int>{};
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..value = 1.0;
  late final Animation<double> _curve =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(_ShellBody old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _built.add(widget.index);
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
            .animate(_curve),
        child: IndexedStack(
          index: widget.index,
          children: [
            for (var i = 0; i < widget.builders.length; i++)
              _built.contains(i)
                  ? widget.builders[i](context)
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

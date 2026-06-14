import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/nav/menu_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('дефолты совпадают с зашитыми иконками вкладок', () async {
    final c = MenuIconsCubit(await SharedPreferences.getInstance());
    expect(c.state.keys, kMenuIconDefaults);
    expect(c.state.iconFor(0), Icons.home_rounded);
    expect(c.state.iconFor(2), Icons.grid_view_rounded);
  });

  test('setIcon сохраняет, перечитывается новым кубитом', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = MenuIconsCubit(prefs);
    c.setIcon(2, 'movie');
    expect(c.state.keys[2], 'movie');
    expect(c.state.iconFor(2), Icons.movie_rounded);
    expect(prefs.getString('menu_icon_2'), 'movie');
    expect(MenuIconsCubit(prefs).state.keys[2], 'movie');
  });

  test('неизвестный ключ / вне диапазона игнорируются', () async {
    final c = MenuIconsCubit(await SharedPreferences.getInstance());
    c.setIcon(1, 'bogus_key');
    expect(c.state.keys[1], 'calendar'); // не изменилось
    c.setIcon(9, 'movie'); // вне диапазона — без падения
    expect(c.state.keys.length, 4);
  });

  test('reset возвращает дефолты и чистит prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = MenuIconsCubit(prefs);
    c.setIcon(0, 'auto_awesome');
    c.setIcon(3, 'tune');
    c.reset();
    expect(c.state.keys, kMenuIconDefaults);
    expect(prefs.getString('menu_icon_0'), isNull);
    expect(prefs.getString('menu_icon_3'), isNull);
  });

  test('navItemsFor строит 4 вкладки с подписями и иконками', () {
    final items = navItemsFor(const MenuIconsState(kMenuIconDefaults));
    expect(items.length, 4);
    expect(items[0].label, 'Главная');
    expect(items[2].label, 'Картотека');
    expect(items[0].icon, Icons.home_rounded);
  });
}

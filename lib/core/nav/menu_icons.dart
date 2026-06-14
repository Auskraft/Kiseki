import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nav_style.dart';

/// Запись пула: стабильный [key] (хранится в prefs) + const [icon] (const-ссылка
/// не вырезается tree-shake'ом иконок).
typedef MenuIconItem = ({String key, IconData icon});

/// Пул иконок для вкладок (стандартные Material `Icons`, rounded). Порядок =
/// порядок в сетке выбора; ключи стабильны — менять/удалять осторожно (сместит
/// сохранённый выбор), добавлять можно куда угодно.
const List<MenuIconItem> kMenuIconPool = [
  (key: 'home', icon: Icons.home_rounded),
  (key: 'cottage', icon: Icons.cottage_rounded),
  (key: 'dashboard', icon: Icons.dashboard_rounded),
  (key: 'space_dashboard', icon: Icons.space_dashboard_rounded),
  (key: 'widgets', icon: Icons.widgets_rounded),
  (key: 'auto_awesome', icon: Icons.auto_awesome_rounded),
  (key: 'calendar', icon: Icons.calendar_month_rounded),
  (key: 'calendar_today', icon: Icons.calendar_today_rounded),
  (key: 'event', icon: Icons.event_rounded),
  (key: 'date_range', icon: Icons.date_range_rounded),
  (key: 'today', icon: Icons.today_rounded),
  (key: 'schedule', icon: Icons.schedule_rounded),
  (key: 'grid', icon: Icons.grid_view_rounded),
  (key: 'view_module', icon: Icons.view_module_rounded),
  (key: 'dashboard_customize', icon: Icons.dashboard_customize_rounded),
  (key: 'category', icon: Icons.category_rounded),
  (key: 'style', icon: Icons.style_rounded),
  (key: 'inventory', icon: Icons.inventory_2_rounded),
  (key: 'collections', icon: Icons.collections_bookmark_rounded),
  (key: 'apps', icon: Icons.apps_rounded),
  (key: 'bookmarks', icon: Icons.bookmarks_rounded),
  (key: 'label', icon: Icons.label_rounded),
  (key: 'movie', icon: Icons.movie_rounded),
  (key: 'theaters', icon: Icons.theaters_rounded),
  (key: 'local_movies', icon: Icons.local_movies_rounded),
  (key: 'restaurant', icon: Icons.restaurant_rounded),
  (key: 'fastfood', icon: Icons.fastfood_rounded),
  (key: 'local_dining', icon: Icons.local_dining_rounded),
  (key: 'liquor', icon: Icons.liquor_rounded),
  (key: 'star', icon: Icons.star_rounded),
  (key: 'favorite', icon: Icons.favorite_rounded),
  (key: 'settings', icon: Icons.settings_rounded),
  (key: 'tune', icon: Icons.tune_rounded),
  (key: 'settings_suggest', icon: Icons.settings_suggest_rounded),
  (key: 'build', icon: Icons.build_rounded),
  (key: 'manage_accounts', icon: Icons.manage_accounts_rounded),
];

/// Дефолтные ключи по 4 вкладкам (0 Главная · 1 Календарь · 2 Картотека ·
/// 3 Настройки) — совпадают с зашитыми иконками [kNavDestinations], поэтому
/// «сброс» возвращает именно их.
const List<String> kMenuIconDefaults = ['home', 'calendar', 'grid', 'settings'];

/// Иконка по ключу; неизвестный ключ → null (вызывающий берёт дефолт).
IconData? menuIconByKey(String key) {
  for (final e in kMenuIconPool) {
    if (e.key == key) return e.icon;
  }
  return null;
}

/// Ключи иконок 4 вкладок (индекс = индекс вкладки).
class MenuIconsState extends Equatable {
  const MenuIconsState(this.keys);

  final List<String> keys;

  /// Иконка вкладки [tab]: кастом из пула, иначе дефолт вкладки, иначе страховка.
  IconData iconFor(int tab) =>
      menuIconByKey(keys[tab]) ??
      menuIconByKey(kMenuIconDefaults[tab]) ??
      Icons.circle_rounded;

  MenuIconsState withTab(int tab, String key) {
    final next = [...keys];
    next[tab] = key;
    return MenuIconsState(next);
  }

  @override
  List<Object?> get props => [keys];
}

/// Вкладки с кастомными иконками + дефолтными подписями [kNavDestinations].
/// Используют и оболочка, и оба превью (нав-стиль + иконки меню).
List<NavBarItem> navItemsFor(MenuIconsState icons) => [
      for (var i = 0; i < kNavDestinations.length; i++)
        NavBarItem(icon: icons.iconFor(i), label: kNavDestinations[i].label),
    ];

/// Хранит и persist'ит кастомные иконки вкладок — синхронно через переданный
/// [SharedPreferences] (паттерн `ThemeCubit`).
class MenuIconsCubit extends Cubit<MenuIconsState> {
  MenuIconsCubit(this._prefs) : super(_initial(_prefs));

  final SharedPreferences _prefs;

  static const _kPrefix = 'menu_icon_'; // menu_icon_0 .. menu_icon_3

  static MenuIconsState _initial(SharedPreferences p) => MenuIconsState([
        for (var i = 0; i < kMenuIconDefaults.length; i++)
          p.getString('$_kPrefix$i') ?? kMenuIconDefaults[i],
      ]);

  /// Назначить иконку вкладке [tab] (применяется сразу — бар обновится).
  void setIcon(int tab, String key) {
    if (tab < 0 || tab >= state.keys.length) return;
    if (menuIconByKey(key) == null) return; // неизвестный ключ игнорируем
    final next = state.withTab(tab, key);
    if (next == state) return;
    emit(next);
    _prefs.setString('$_kPrefix$tab', key);
  }

  /// Сброс всех вкладок к стандартным иконкам.
  void reset() {
    const def = MenuIconsState(kMenuIconDefaults);
    if (state == def) return;
    emit(def);
    for (var i = 0; i < kMenuIconDefaults.length; i++) {
      _prefs.remove('$_kPrefix$i');
    }
  }
}

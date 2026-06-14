import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Стиль нижней навигации. Выбирается в Настройки → Визуальный стиль → Стиль
/// навигации; значение и параметры бара (стекло/градиент) хранятся в
/// SharedPreferences. Новый стиль = значение enum + виджет-бар + ветка в
/// оболочке + превью в пикере.
enum NavBarStyle {
  /// «Жидкий» плавающий бар: светящийся шар-капля перетекает между вкладками.
  floating,

  /// Классический: скользящий индикатор, подписи у всех вкладок.
  classic,

  /// «Капсула»: активная вкладка раскрыта в капсулу с подписью и анимированным
  /// градиентом; остальные — иконки-кружки.
  capsule;

  String get id => name;

  static NavBarStyle fromId(String? id) => NavBarStyle.values.firstWhere(
        (s) => s.id == id,
        orElse: () => NavBarStyle.capsule,
      );

  /// Короткое название (чип в пикере, строка в настройках).
  String get title => switch (this) {
        NavBarStyle.floating => 'Жидкий',
        NavBarStyle.classic => 'Классический',
        NavBarStyle.capsule => 'Капсула',
      };

  /// Описание под живым превью.
  String get description => switch (this) {
        NavBarStyle.floating =>
          'Светящийся шар перетекает между вкладками каплей.',
        NavBarStyle.classic => 'Скользящий индикатор и подписи у всех вкладок.',
        NavBarStyle.capsule =>
          'Активная вкладка раскрывается в капсулу с анимированным градиентом.',
      };
}

/// Одна вкладка нижней навигации (иконка + подпись). Иконки пока фиксированы;
/// кастомизация — будущий экран «Иконки меню».
@immutable
class NavBarItem {
  const NavBarItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Четыре раздела приложения — единый источник для оболочки и превью пикера.
const List<NavBarItem> kNavDestinations = [
  NavBarItem(icon: Icons.home_rounded, label: 'Главная'),
  NavBarItem(icon: Icons.calendar_month_rounded, label: 'Календарь'),
  NavBarItem(icon: Icons.grid_view_rounded, label: 'Картотека'),
  NavBarItem(icon: Icons.settings_rounded, label: 'Настройки'),
];

/// Состояние навигации: выбранный стиль + общие параметры оформления бара.
class NavStyleState extends Equatable {
  const NavStyleState({
    required this.style,
    required this.glass,
    required this.glassLevel,
    required this.gradient,
  });

  final NavBarStyle style;

  /// «Эффект стекла» (frosted blur + полупрозрачный фон) — общий для всех баров.
  final bool glass;

  /// Степень стекла 0..[NavStyleCubit.maxGlassLevel] (плотно → прозрачно).
  final int glassLevel;

  /// Анимированный градиент активной капсулы (только стиль «Капсула»).
  final bool gradient;

  NavStyleState copyWith({
    NavBarStyle? style,
    bool? glass,
    int? glassLevel,
    bool? gradient,
  }) =>
      NavStyleState(
        style: style ?? this.style,
        glass: glass ?? this.glass,
        glassLevel: glassLevel ?? this.glassLevel,
        gradient: gradient ?? this.gradient,
      );

  @override
  List<Object?> get props => [style, glass, glassLevel, gradient];
}

/// Хранит и persist'ит стиль навигации и параметры бара — синхронно через
/// переданный [SharedPreferences] (паттерн `ThemeCubit`, prefs уже в `getIt`).
class NavStyleCubit extends Cubit<NavStyleState> {
  NavStyleCubit(this._prefs) : super(_initial(_prefs));

  final SharedPreferences _prefs;

  /// Максимальная ступень стекла (всего 6 положений: 0..5).
  static const int maxGlassLevel = 5;

  static const _kStyle = 'nav_bar_style';
  static const _kGlass = 'nav_glass_effect';
  static const _kGlassLevel = 'nav_glass_level';
  static const _kGradient = 'nav_gradient_anim';

  static NavStyleState _initial(SharedPreferences p) => NavStyleState(
        style: NavBarStyle.fromId(p.getString(_kStyle)),
        glass: p.getBool(_kGlass) ?? true,
        glassLevel: (p.getInt(_kGlassLevel) ?? 2).clamp(0, maxGlassLevel),
        gradient: p.getBool(_kGradient) ?? true,
      );

  void setStyle(NavBarStyle style) {
    if (style == state.style) return;
    emit(state.copyWith(style: style));
    _prefs.setString(_kStyle, style.id);
  }

  void setGlass(bool value) {
    if (value == state.glass) return;
    emit(state.copyWith(glass: value));
    _prefs.setBool(_kGlass, value);
  }

  void setGlassLevel(int value) {
    final v = value.clamp(0, maxGlassLevel);
    if (v == state.glassLevel) return;
    emit(state.copyWith(glassLevel: v));
    _prefs.setInt(_kGlassLevel, v);
  }

  void setGradient(bool value) {
    if (value == state.gradient) return;
    emit(state.copyWith(gradient: value));
    _prefs.setBool(_kGradient, value);
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kiseki_theme_id.dart';

class ThemeState extends Equatable {
  const ThemeState({required this.themeId, required this.themeMode});

  final KisekiThemeId themeId;
  final ThemeMode themeMode;

  ThemeState copyWith({KisekiThemeId? themeId, ThemeMode? themeMode}) =>
      ThemeState(
        themeId: themeId ?? this.themeId,
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  List<Object?> get props => [themeId, themeMode];
}

/// Глобальное состояние темы (тема + режим), персист в shared_preferences.
/// Смена — мгновенная перекраска всего UI (вёрстка не меняется, ADR-17).
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._prefs) : super(_initial(_prefs));

  final SharedPreferences _prefs;

  static const _kTheme = 'kiseki_theme';
  static const _kMode = 'kiseki_mode';

  static ThemeState _initial(SharedPreferences p) {
    final id = KisekiThemeId.fromName(p.getString(_kTheme) ?? 'base');
    final mode = switch (p.getString(_kMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return ThemeState(themeId: id, themeMode: mode);
  }

  void setTheme(KisekiThemeId id) {
    emit(state.copyWith(themeId: id));
    _prefs.setString(_kTheme, id.name);
  }

  void setMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
    _prefs.setString(_kMode, mode.name);
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Вид кнопки добавления (FAB). Настройки → Визуальный стиль → Стиль кнопки
/// добавления. Значение и оформление (стекло/градиент) — в SharedPreferences.
enum FabStyle {
  /// Круглая кнопка с иконкой.
  plain,

  /// Пилюля с иконкой и подписью.
  labeled;

  String get id => name;

  static FabStyle fromId(String? id) => FabStyle.values.firstWhere(
        (s) => s.id == id,
        orElse: () => FabStyle.labeled,
      );

  String get title => switch (this) {
        FabStyle.plain => 'Иконка',
        FabStyle.labeled => 'С подписью',
      };

  String get description => switch (this) {
        FabStyle.plain => 'Круглая кнопка только с иконкой.',
        FabStyle.labeled => 'Пилюля с иконкой и подписью.',
      };
}

/// Состояние FAB: вид + оформление заливки. Заливка: стекло (если включено),
/// иначе анимированный градиент (если включён), иначе сплошной акцент.
class FabStyleState extends Equatable {
  const FabStyleState({
    required this.style,
    required this.glass,
    required this.glassLevel,
    required this.gradient,
  });

  final FabStyle style;

  /// «Эффект стекла» (frosted blur + полупрозрачная заливка).
  final bool glass;

  /// Степень стекла 0..[FabStyleCubit.maxGlassLevel].
  final int glassLevel;

  /// Анимированный «дышащий» градиент акцентов (когда стекло выключено).
  final bool gradient;

  FabStyleState copyWith({
    FabStyle? style,
    bool? glass,
    int? glassLevel,
    bool? gradient,
  }) =>
      FabStyleState(
        style: style ?? this.style,
        glass: glass ?? this.glass,
        glassLevel: glassLevel ?? this.glassLevel,
        gradient: gradient ?? this.gradient,
      );

  @override
  List<Object?> get props => [style, glass, glassLevel, gradient];
}

/// Хранит и persist'ит стиль FAB — синхронно через переданный
/// [SharedPreferences] (паттерн `ThemeCubit`/`NavStyleCubit`).
class FabStyleCubit extends Cubit<FabStyleState> {
  FabStyleCubit(this._prefs) : super(_initial(_prefs));

  final SharedPreferences _prefs;

  static const int maxGlassLevel = 5;

  static const _kStyle = 'fab_style';
  static const _kGlass = 'fab_glass_effect';
  static const _kGlassLevel = 'fab_glass_level';
  static const _kGradient = 'fab_gradient_anim';

  static FabStyleState _initial(SharedPreferences p) => FabStyleState(
        style: FabStyle.fromId(p.getString(_kStyle)),
        glass: p.getBool(_kGlass) ?? false,
        glassLevel: (p.getInt(_kGlassLevel) ?? 2).clamp(0, maxGlassLevel),
        gradient: p.getBool(_kGradient) ?? true,
      );

  void setStyle(FabStyle style) {
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

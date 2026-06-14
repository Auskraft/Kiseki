/// Структурные токены (одинаковы для всех тем). Значения слегка уменьшены
/// относительно хэндоффа — интерфейс делаем компактнее (см. [uiScale]).
/// Меняешь масштаб ЗДЕСЬ — меняется во всём приложении.
library;

/// Глобальный коэффициент уменьшения типографики/некоторых размеров
/// относительно дизайна (1.0 = как в хэндоффе). Подбирается на глаз.
const double uiScale = 0.88;

abstract final class AppSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
}

abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 11;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 30;
  static const double pill = 999;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);

  /// Морф цветов при смене темы в рантайме.
  static const Duration themeMorph = Duration(milliseconds: 500);
}

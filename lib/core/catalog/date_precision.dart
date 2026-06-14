/// Точность пользовательской даты (ядро): день / месяц / год.
/// Позволяет хранить приблизительные даты («помню только год») без потери
/// сортируемости (TECH_DESIGN §6.6).
enum DatePrecision {
  day('day'),
  month('month'),
  year('year');

  const DatePrecision(this.code);

  final String code;

  static DatePrecision fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown DatePrecision code: $code'),
      );
}

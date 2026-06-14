/// Набор тем (у каждой — режим light/dark). Расширяется добавлением значения
/// + палитры в [kiseki_themes.dart]. Хэндофф: 5 тем.
enum KisekiThemeId {
  base('Kiseki'),
  sakura('Сакура'),
  matcha('Матча'),
  midnight('Полночь'),
  sunset('Закат');

  const KisekiThemeId(this.label);

  /// Человекочитаемое название (для пикера тем).
  final String label;

  static KisekiThemeId fromName(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => KisekiThemeId.base,
      );
}

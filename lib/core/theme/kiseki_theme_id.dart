/// Набор тем (у каждой — режим light/dark). Расширяется добавлением значения
/// + палитры в [kiseki_themes.dart]. 5 тем хэндоффа заданы вручную, остальные
/// выведены из акцента через `_derive`.
enum KisekiThemeId {
  base('Kiseki'),
  sakura('Сакура'),
  matcha('Матча'),
  midnight('Полночь'),
  sunset('Закат'),
  ocean('Океан'),
  lavender('Лаванда'),
  cherry('Вишня'),
  amber('Янтарь'),
  sky('Небо'),
  ink('Графит');

  const KisekiThemeId(this.label);

  /// Человекочитаемое название (для пикера тем).
  final String label;

  static KisekiThemeId fromName(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => KisekiThemeId.base,
      );
}

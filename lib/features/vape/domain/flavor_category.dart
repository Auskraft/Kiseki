/// Основная категория вкуса жидкости. `code` — стабильная строка для БД/бэкапа.
enum FlavorCategory {
  fruits('fruits'),
  berries('berries'),
  drinks('drinks'),
  desserts('desserts'),
  tobacco('tobacco'),
  menthol('menthol'),
  mixes('mixes');

  const FlavorCategory(this.code);

  final String code;

  String get label => switch (this) {
        FlavorCategory.fruits => 'Фрукты',
        FlavorCategory.berries => 'Ягоды',
        FlavorCategory.drinks => 'Напитки',
        FlavorCategory.desserts => 'Десерты',
        FlavorCategory.tobacco => 'Табак',
        FlavorCategory.menthol => 'Ментол / холодок',
        FlavorCategory.mixes => 'Миксы',
      };

  static FlavorCategory fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown FlavorCategory code: $code'),
      );
}

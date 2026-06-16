/// Домен записи картотеки: `media` (просмотры) и `vape` (жидкости для вейпа).
/// Будущие — `food`, `restaurant` (добавляются новой доменной таблицей 1:1,
/// ядро не трогаем — ADR-02).
enum CatalogDomain {
  media('media'),
  vape('vape');

  const CatalogDomain(this.code);

  final String code;

  static CatalogDomain fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown CatalogDomain code: $code'),
      );
}

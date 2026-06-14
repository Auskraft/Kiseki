/// Домен записи картотеки. Сейчас только `media`; будущие — `food`,
/// `restaurant`, `vape` (добавляются новой доменной таблицей, ядро не трогаем).
enum CatalogDomain {
  media('media');

  const CatalogDomain(this.code);

  final String code;

  static CatalogDomain fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown CatalogDomain code: $code'),
      );
}

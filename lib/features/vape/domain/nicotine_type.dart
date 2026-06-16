/// Тип никотина в жидкости. `code` — стабильная строка для БД/бэкапа.
enum NicotineType {
  salt('salt'),
  alkaline('alkaline'),
  hybrid('hybrid');

  const NicotineType(this.code);

  final String code;

  String get label => switch (this) {
        NicotineType.salt => 'Солевой',
        NicotineType.alkaline => 'Щелочной',
        NicotineType.hybrid => 'Гибрид',
      };

  static NicotineType fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown NicotineType code: $code'),
      );
}

/// «Фильм vs сериал» в чистом виде (ADR-07). Это, а не `media_type`,
/// определяет наличие блока сезон/серия: аниме бывает фильмом (`single`),
/// веб-дорама — одиночкой.
enum MediaFormat {
  /// Единое произведение без эпизодов (фильм, аниме-фильм, OVA-одиночка).
  single('single'),

  /// Есть эпизоды/сезоны (сериал, дорама, многосерийное аниме).
  episodic('episodic');

  const MediaFormat(this.code);

  final String code;

  static MediaFormat fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown MediaFormat code: $code'),
      );
}

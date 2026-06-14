import 'media_format.dart';

/// Тип медиа — классификатор (иконки, фильтр, страна по умолчанию).
/// Эпизодность определяется отдельным полем [MediaFormat], а не этим типом.
enum MediaType {
  movie('movie'),
  series('series'),
  drama('drama'),
  anime('anime');

  const MediaType(this.code);

  final String code;

  static MediaType fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown MediaType code: $code'),
      );

  /// Дефолтный формат по типу (пользователь может переопределить).
  MediaFormat get defaultFormat =>
      this == MediaType.movie ? MediaFormat.single : MediaFormat.episodic;

  /// Подпись для UI (позже — через l10n).
  String get label => switch (this) {
        MediaType.movie => 'Фильм',
        MediaType.series => 'Сериал',
        MediaType.drama => 'Дорама',
        MediaType.anime => 'Аниме',
      };
}

import 'media_format.dart';

/// Вид медиа — конкретная категория (Фильм, Аниме, Дорама, Мультфильм…).
/// Эпизодность несёт ОТДЕЛЬНОЕ поле [MediaFormat] (ADR-07): один и тот же вид
/// бывает «одиночным» и «серийным», поэтому пользовательская подпись зависит
/// от формата ([labelFor]) — «Фильм»/«Сериал», «Полнометражное аниме»/
/// «Аниме-сериал» и т.д. Порядок значений = порядок чипов в форме и фильтре.
enum MediaType {
  movie('movie'),
  anime('anime'),
  drama('drama'),
  cartoon('cartoon'),
  documentary('documentary'),
  concert('concert'),
  tvShow('tv_show'),
  ova('ova'),
  ona('ona'),
  tvPlay('tv_play');

  const MediaType(this.code);

  final String code;

  static MediaType fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown MediaType code: $code'),
      );

  /// Подпись с учётом формата. Одна категория читается по-разному:
  /// `single` → одиночная форма, `episodic` → серийная (см. реестр §2 /
  /// дизайн-таблицу видов).
  String labelFor(MediaFormat format) {
    final episodic = format == MediaFormat.episodic;
    return switch (this) {
      MediaType.movie => episodic ? 'Сериал' : 'Фильм',
      MediaType.anime => episodic ? 'Аниме-сериал' : 'Полнометражное аниме',
      MediaType.drama => episodic ? 'Дорама' : 'Полнометражная дорама (редко)',
      MediaType.cartoon => episodic ? 'Мультсериал' : 'Мультфильм',
      MediaType.documentary =>
        episodic ? 'Документальный сериал' : 'Документальный фильм',
      MediaType.concert =>
        episodic ? 'Концертный сериал / шоу' : 'Концертный фильм',
      MediaType.tvShow => episodic ? 'ТВ-шоу' : 'Спецвыпуск',
      MediaType.ova => episodic ? 'OVA-серия' : 'OVA (1 выпуск)',
      MediaType.ona => episodic ? 'ONA-серия' : 'ONA (1 выпуск)',
      MediaType.tvPlay => episodic ? 'Телепередача' : 'Телеспектакль',
    };
  }

  /// Нейтральная (формат-независимая) подпись категории — для фильтра и мест,
  /// где формат записи неизвестен.
  String get label => switch (this) {
        MediaType.movie => 'Фильм/сериал',
        MediaType.anime => 'Аниме',
        MediaType.drama => 'Дорама',
        MediaType.cartoon => 'Мультфильм',
        MediaType.documentary => 'Документальное',
        MediaType.concert => 'Концерт',
        MediaType.tvShow => 'ТВ-шоу',
        MediaType.ova => 'OVA',
        MediaType.ona => 'ONA',
        MediaType.tvPlay => 'Телеспектакль',
      };
}

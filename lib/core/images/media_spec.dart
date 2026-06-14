/// Параметры конвейера изображений (TECH_DESIGN §7.1). Максимум 512×512.
abstract final class MediaSpec {
  /// Длинная сторона полного изображения, px.
  static const int fullEdge = 512;
  static const int fullQuality = 80;

  /// Длинная сторона thumbnail, px (вилка ТЗ 128–160).
  static const int thumbEdge = 150;
  static const int thumbQuality = 75;

  /// Отсечка «слишком большой файл» до декодирования.
  static const int maxInputBytes = 25 * 1024 * 1024;
}

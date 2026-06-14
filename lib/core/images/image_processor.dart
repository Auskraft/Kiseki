import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../error/failures.dart';
import 'media_spec.dart';

/// Результат сжатия: два размера в WebP.
class EncodedImage {
  const EncodedImage(this.full, this.thumb);
  final Uint8List full;
  final Uint8List thumb;
}

/// Абстракция сжатия (за интерфейсом — чтобы тестировать [ImageStorage] без
/// нативного плагина).
abstract interface class ImageProcessor {
  Future<EncodedImage> process(String sourcePath);
}

/// Боевая реализация на `flutter_image_compress` (нативный WebP-кодек).
/// Оба размера кодируются из ОРИГИНАЛА (без двойного lossy), EXIF-ориентация
/// запекается в пиксели, метаданные отбрасываются.
class FlutterImageProcessor implements ImageProcessor {
  const FlutterImageProcessor();

  @override
  Future<EncodedImage> process(String sourcePath) async {
    final full = await _compress(sourcePath, MediaSpec.fullEdge, MediaSpec.fullQuality);
    final thumb = await _compress(sourcePath, MediaSpec.thumbEdge, MediaSpec.thumbQuality);
    if (full == null || thumb == null) throw const ImageDecodeFailure();
    return EncodedImage(full, thumb);
  }

  Future<Uint8List?> _compress(String path, int edge, int quality) {
    return FlutterImageCompress.compressWithFile(
      path,
      minWidth: edge,
      minHeight: edge,
      quality: quality,
      format: CompressFormat.webp,
      keepExif: false,
      autoCorrectionAngle: true,
    );
  }
}

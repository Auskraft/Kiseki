import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../error/failures.dart';
import 'image_processor.dart';
import 'media_paths.dart';
import 'media_spec.dart';

/// Хранилище файлов картинок: сжатие -> `.tmp` -> атомарный rename ->
/// финальные папки (TECH_DESIGN §7.3). Работает по UUID, доменно-нейтрально.
class ImageStorage {
  ImageStorage(this._paths, this._processor, {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  final MediaPaths _paths;
  final ImageProcessor _processor;
  final Uuid _uuid;

  /// Сжать исходник в два размера и сохранить. Возвращает UUID картинки
  /// (вызывающий слой связывает его с записью в БД).
  Future<String> save(String sourcePath) async {
    final input = File(sourcePath);
    if (await input.length() > MediaSpec.maxInputBytes) {
      throw const ImageTooLargeFailure();
    }
    final encoded = await _processor.process(sourcePath);
    final id = _uuid.v4();

    await _paths.tmpDir.create(recursive: true);
    await _paths.fullDir.create(recursive: true);
    await _paths.thumbDir.create(recursive: true);

    final tmpFull = File(p.join(_paths.tmpDir.path, '$id.full.tmp'));
    final tmpThumb = File(p.join(_paths.tmpDir.path, '$id.thumb.tmp'));
    await tmpFull.writeAsBytes(encoded.full, flush: true);
    await tmpThumb.writeAsBytes(encoded.thumb, flush: true);

    // Атомарная публикация: пока rename не прошёл, в боевых папках мусора нет.
    await tmpFull.rename(_paths.absFull(id).path);
    await tmpThumb.rename(_paths.absThumb(id).path);
    return id;
  }

  /// Удалить оба файла картинки (вызывать ПОСЛЕ коммита БД).
  Future<void> deleteFiles(String id) async {
    for (final f in [_paths.absFull(id), _paths.absThumb(id)]) {
      if (await f.exists()) await f.delete();
    }
  }

  /// Удалить файлы-сироты (нет ссылки в БД) и очистить `.tmp`.
  /// [liveIds] — множество всех `image_id` из БД. Возвращает число удалённых.
  Future<int> sweepOrphans(Set<String> liveIds) async {
    var removed = 0;
    for (final dir in [_paths.fullDir, _paths.thumbDir]) {
      if (!await dir.exists()) continue;
      await for (final entity in dir.list()) {
        if (entity is File) {
          final id = p.basenameWithoutExtension(entity.path);
          if (!liveIds.contains(id)) {
            await entity.delete();
            removed++;
          }
        }
      }
    }
    if (await _paths.tmpDir.exists()) {
      await for (final entity in _paths.tmpDir.list()) {
        if (entity is File) await entity.delete();
      }
    }
    return removed;
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/images/image_processor.dart';
import 'package:kiseki/core/images/image_storage.dart';
import 'package:kiseki/core/images/media_paths.dart';
import 'package:path/path.dart' as p;

/// Фейковый процессор: возвращает фиксированные байты без нативного кодека.
class _FakeProcessor implements ImageProcessor {
  @override
  Future<EncodedImage> process(String sourcePath) async => EncodedImage(
        Uint8List.fromList([1, 2, 3, 4]),
        Uint8List.fromList([9]),
      );
}

void main() {
  late Directory root;
  late MediaPaths paths;
  late ImageStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('kiseki_img_');
    paths = MediaPaths(root);
    storage = ImageStorage(paths, _FakeProcessor());
  });
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<String> sourceFile() async {
    final f = File(p.join(root.path, 'src.jpg'));
    await f.writeAsBytes([0, 0, 0]);
    return f.path;
  }

  test('save writes full+thumb to webp paths and returns id', () async {
    final id = await storage.save(await sourceFile());

    expect(await paths.absFull(id).exists(), isTrue);
    expect(await paths.absThumb(id).exists(), isTrue);
    expect(await paths.absFull(id).readAsBytes(), [1, 2, 3, 4]);
    expect(await paths.absThumb(id).readAsBytes(), [9]);
    // tmp очищается атомарным rename — никаких .tmp-хвостов.
    final tmp = paths.tmpDir;
    final leftovers = await tmp.exists() ? tmp.listSync() : const [];
    expect(leftovers, isEmpty);
  });

  test('deleteFiles removes both sizes', () async {
    final id = await storage.save(await sourceFile());
    await storage.deleteFiles(id);
    expect(await paths.absFull(id).exists(), isFalse);
    expect(await paths.absThumb(id).exists(), isFalse);
  });

  test('sweepOrphans deletes unreferenced files, keeps live ones', () async {
    final keep = await storage.save(await sourceFile());
    final drop = await storage.save(await sourceFile());

    final removed = await storage.sweepOrphans({keep});

    expect(removed, 2); // full + thumb сироты
    expect(await paths.absFull(keep).exists(), isTrue);
    expect(await paths.absThumb(keep).exists(), isTrue);
    expect(await paths.absFull(drop).exists(), isFalse);
    expect(await paths.absThumb(drop).exists(), isFalse);
  });
}

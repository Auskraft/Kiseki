import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/images/image_processor.dart';
import 'package:kiseki/core/images/image_storage.dart';
import 'package:kiseki/core/images/media_paths.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_trash_cubit.dart';
import 'package:path/path.dart' as p;

/// Без нативного кодека: отдаёт фиктивные WebP-байты.
class _FakeProcessor implements ImageProcessor {
  @override
  Future<EncodedImage> process(String sourcePath) async =>
      EncodedImage(Uint8List.fromList([1, 2, 3]), Uint8List.fromList([4, 5, 6]));
}

void main() {
  late AppDatabase db;
  late MediaRepositoryImpl repo;
  late Directory tmpRoot;
  late MediaPaths paths;
  late ImageStorage images;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MediaRepositoryImpl(db);
    tmpRoot = Directory.systemTemp.createTempSync('kiseki_trash_test_');
    paths = MediaPaths(tmpRoot);
    images = ImageStorage(paths, _FakeProcessor());
  });
  tearDown(() async {
    await db.close();
    if (tmpRoot.existsSync()) tmpRoot.deleteSync(recursive: true);
  });

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  Future<String> trashed(String title) async {
    final id = await repo.create(MediaDraft(
      title: title,
      mediaType: MediaType.movie,
      format: MediaFormat.single,
    ));
    await repo.softDelete(id);
    return id;
  }

  test('показывает корзину; восстановление убирает запись из неё', () async {
    final id = await trashed('A');
    final cubit = MediaTrashCubit(repo, images);
    addTearDown(cubit.close);

    await settle();
    expect(cubit.state.items.map((e) => e.id), [id]);

    await cubit.restore(id);
    await settle();
    expect(cubit.state.items, isEmpty);
    expect((await repo.findById(id))!.isInTrash, isFalse);
  });

  test('purge удаляет запись окончательно', () async {
    final id = await trashed('A');
    final cubit = MediaTrashCubit(repo, images);
    addTearDown(cubit.close);
    await settle();

    await cubit.purge(id);
    await settle();
    expect(cubit.state.items, isEmpty);
    expect(await repo.findById(id), isNull);
  });

  test('purge удаляет файлы обложки с диска (§7.3)', () async {
    final src = File(p.join(tmpRoot.path, 'src.jpg'))
      ..writeAsBytesSync([0, 1, 2, 3]);
    final imageId = await images.save(src.path);
    final id = await repo.create(MediaDraft(
      title: 'С обложкой',
      mediaType: MediaType.movie,
      format: MediaFormat.single,
      coverImageId: imageId,
    ));
    await repo.softDelete(id);
    expect(paths.absFull(imageId).existsSync(), isTrue);
    expect(paths.absThumb(imageId).existsSync(), isTrue);

    final cubit = MediaTrashCubit(repo, images);
    addTearDown(cubit.close);
    await settle();

    await cubit.purge(id);
    await settle();
    expect(await repo.findById(id), isNull);
    expect(paths.absFull(imageId).existsSync(), isFalse,
        reason: 'hard-delete должен удалять файл full');
    expect(paths.absThumb(imageId).existsSync(), isFalse,
        reason: 'hard-delete должен удалять файл thumb');
  });

  test('purgeAll очищает корзину целиком', () async {
    await trashed('A');
    await trashed('B');
    final cubit = MediaTrashCubit(repo, images);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.items, hasLength(2));

    await cubit.purgeAll();
    await settle();
    expect(cubit.state.items, isEmpty);
  });
}

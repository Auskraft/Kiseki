import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_trash_cubit.dart';

void main() {
  late AppDatabase db;
  late MediaRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MediaRepositoryImpl(db);
  });
  tearDown(() => db.close());

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
    final cubit = MediaTrashCubit(repo);
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
    final cubit = MediaTrashCubit(repo);
    addTearDown(cubit.close);
    await settle();

    await cubit.purge(id);
    await settle();
    expect(cubit.state.items, isEmpty);
    expect(await repo.findById(id), isNull);
  });

  test('purgeAll очищает корзину целиком', () async {
    await trashed('A');
    await trashed('B');
    final cubit = MediaTrashCubit(repo);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.items, hasLength(2));

    await cubit.purgeAll();
    await settle();
    expect(cubit.state.items, isEmpty);
  });
}

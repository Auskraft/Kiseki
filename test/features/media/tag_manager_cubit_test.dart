import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/features/media/presentation/cubit/tag_manager_cubit.dart';

void main() {
  late AppDatabase db;
  late TagRepositoryImpl tags;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tags = TagRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  test('реактивный список + создание тега', () async {
    final cubit = TagManagerCubit(tags);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.tags, isEmpty);

    await cubit.create('Драма');
    await settle();
    expect(cubit.state.tags.map((t) => t.tag.name), ['Драма']);
    expect(cubit.state.tags.single.count, 0);
  });

  test('rename и delete отражаются в списке', () async {
    final tag = await tags.ensure('Драмма');
    final cubit = TagManagerCubit(tags);
    addTearDown(cubit.close);
    await settle();

    await cubit.rename(tag.id, 'Драма');
    await settle();
    expect(cubit.state.tags.single.tag.name, 'Драма');

    await cubit.delete(tag.id);
    await settle();
    expect(cubit.state.tags, isEmpty);
  });

  test('merge убирает исходный тег из списка', () async {
    final a = await tags.ensure('Sci-Fi');
    final b = await tags.ensure('Фантастика');
    final cubit = TagManagerCubit(tags);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.tags, hasLength(2));

    await cubit.merge(a.id, b.id);
    await settle();
    expect(cubit.state.tags.map((t) => t.tag.name), ['Фантастика']);
  });
}

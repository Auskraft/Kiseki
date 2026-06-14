import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/error/failures.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';

void main() {
  late AppDatabase db;
  late TagRepositoryImpl tags;
  late MediaRepositoryImpl media;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tags = TagRepositoryImpl(db);
    media = MediaRepositoryImpl(db);
  });
  tearDown(() => db.close());

  MediaDraft draft(List<String> tagIds) => MediaDraft(
        title: 'X',
        mediaType: MediaType.movie,
        format: MediaFormat.single,
        tagIds: tagIds,
      );

  test('watchAllWithCounts считает только живые карточки', () async {
    final drama = await tags.ensure('Драма');
    await media.create(draft([drama.id]));
    await media.create(draft([drama.id]));
    final trashed = await media.create(draft([drama.id]));
    await media.softDelete(trashed);

    final counts = await tags.watchAllWithCounts().first;
    expect(counts.single.tag.id, drama.id);
    expect(counts.single.count, 2, reason: 'карточка в корзине не считается');
  });

  test('merge переносит связи на целевой тег и удаляет исходный', () async {
    final scifi = await tags.ensure('Sci-Fi');
    final fantasy = await tags.ensure('Фантастика');
    final only = await media.create(draft([scifi.id]));
    final both = await media.create(draft([scifi.id, fantasy.id]));

    await tags.merge(scifi.id, fantasy.id);

    expect((await tags.all()).map((t) => t.id), [fantasy.id]);
    expect((await media.findById(only))!.tags.map((t) => t.id), [fantasy.id]);
    // У карточки, уже имевшей оба тега, дубля не возникло.
    expect((await media.findById(both))!.tags.map((t) => t.id), [fantasy.id]);
  });

  test('merge в самого себя — no-op', () async {
    final a = await tags.ensure('A');
    await tags.merge(a.id, a.id);
    expect(await tags.all(), hasLength(1));
  });

  test('rename в имя другого тега бросает TagNameTakenFailure', () async {
    await tags.ensure('Драма');
    final comedy = await tags.ensure('Комедия');

    // Регистр/пробелы нормализуются — «  ДРАМА » конфликтует с «Драма».
    await expectLater(
      tags.rename(comedy.id, '  ДРАМА '),
      throwsA(isA<TagNameTakenFailure>()),
    );

    // UPDATE не выполнился: оба тега целы, имена не изменились.
    final names = (await tags.all()).map((t) => t.name).toList();
    expect(names, containsAll(['Драма', 'Комедия']));
    expect((await tags.all()).firstWhere((t) => t.id == comedy.id).name,
        'Комедия');
  });

  test('rename того же тега (смена регистра) не считается коллизией', () async {
    final drama = await tags.ensure('драма');
    await tags.rename(drama.id, 'Драма');
    expect((await tags.all()).single.name, 'Драма');
  });
}

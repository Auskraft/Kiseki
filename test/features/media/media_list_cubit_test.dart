import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_query.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_list_cubit.dart';

void main() {
  late AppDatabase db;
  late MediaRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MediaRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  MediaDraft movie(String title, {WatchStatus status = WatchStatus.plan}) =>
      MediaDraft(
        title: title,
        mediaType: MediaType.movie,
        format: MediaFormat.single,
        status: status,
      );

  test('setSearch фильтрует список и resetFilters возвращает всё', () async {
    await repo.create(movie('Дюна'));
    await repo.create(movie('Матрица'));
    final cubit = MediaListCubit(repo);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.items, hasLength(2));

    cubit.setSearch('дюна');
    await settle();
    expect(cubit.state.items.map((e) => e.title), ['Дюна']);
    expect(cubit.state.hasSearchOrFilter, isTrue);

    cubit.resetFilters();
    await settle();
    expect(cubit.state.items, hasLength(2));
    expect(cubit.state.hasSearchOrFilter, isFalse);
  });

  test('фильтр по статусу; полки скрыты при активном фильтре', () async {
    await repo.create(movie('A', status: WatchStatus.watching));
    await repo.create(movie('B', status: WatchStatus.completed));
    final cubit = MediaListCubit(repo);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.watchingNow.map((e) => e.title), ['A']);

    cubit.setQuery(const MediaListQuery(statuses: {WatchStatus.completed}));
    await settle();
    expect(cubit.state.items.map((e) => e.title), ['B']);
    expect(cubit.state.watchingNow, isEmpty,
        reason: 'полки прячутся под фильтром');
  });

  test('noResults при пустом результате (не онбординг)', () async {
    await repo.create(movie('Дюна'));
    final cubit = MediaListCubit(repo);
    addTearDown(cubit.close);
    await settle();

    cubit.setSearch('zzz');
    await settle();
    expect(cubit.state.items, isEmpty);
    expect(cubit.state.noResults, isTrue);
    expect(cubit.state.isEmpty, isFalse);
  });

  test('setViewMode переключает грид/список', () async {
    final cubit = MediaListCubit(repo);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state.viewMode, ViewMode.grid);
    cubit.setViewMode(ViewMode.list);
    expect(cubit.state.viewMode, ViewMode.list);
  });
}

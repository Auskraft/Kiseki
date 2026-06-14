import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/unfinished_reason.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_detail_cubit.dart';

void main() {
  late AppDatabase db;
  late MediaRepositoryImpl repo;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MediaRepositoryImpl(db, clock: () => now);
  });
  tearDown(() => db.close());

  // Дать Drift-стриму отработать пере-эмит после мутации.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  MediaDraft draft({
    WatchStatus status = WatchStatus.watching,
    bool favorite = false,
  }) =>
      MediaDraft(
        title: 'Во все тяжкие',
        mediaType: MediaType.series,
        format: MediaFormat.episodic,
        status: status,
        isFavorite: favorite,
        currentSeason: 2,
        currentEpisode: 5,
        totalEpisodes: 62,
      );

  test('подгружает запись и переключает избранное', () async {
    final id = await repo.create(draft());
    final cubit = MediaDetailCubit(repo, id);
    addTearDown(cubit.close);

    await settle();
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.entry!.id, id);
    expect(cubit.state.entry!.isFavorite, isFalse);

    await cubit.toggleFavorite();
    await settle();
    expect(cubit.state.entry!.isFavorite, isTrue);
  });

  test('setStatus отражается в состоянии (пауза + жду серии)', () async {
    final id = await repo.create(draft());
    final cubit = MediaDetailCubit(repo, id);
    addTearDown(cubit.close);
    await settle();

    await cubit.setStatus(WatchStatus.paused,
        reason: UnfinishedReason.waitingEpisodes);
    await settle();
    expect(cubit.state.entry!.status, WatchStatus.paused);
    expect(cubit.state.entry!.unfinishedReason,
        UnfinishedReason.waitingEpisodes);
  });

  test('incrementEvent увеличивает счётчик пересмотров', () async {
    final id = await repo.create(draft());
    final cubit = MediaDetailCubit(repo, id);
    addTearDown(cubit.close);
    await settle();

    await cubit.incrementEvent();
    await settle();
    expect(cubit.state.entry!.rewatchCount, 1);
  });

  test('softDelete помечает корзину, запись остаётся видимой детали', () async {
    final id = await repo.create(draft());
    final cubit = MediaDetailCubit(repo, id);
    addTearDown(cubit.close);
    await settle();

    await cubit.softDelete();
    await settle();
    expect(cubit.state.entry!.isInTrash, isTrue);
  });
}

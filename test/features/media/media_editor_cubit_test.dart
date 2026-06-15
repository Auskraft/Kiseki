import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/tag_repository_impl.dart';
import 'package:kiseki/core/catalog/unfinished_reason.dart';
import 'package:kiseki/core/catalog/watch_status.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/core/error/failures.dart';
import 'package:kiseki/core/images/image_processor.dart';
import 'package:kiseki/core/images/image_storage.dart';
import 'package:kiseki/core/images/media_paths.dart';
import 'package:kiseki/features/media/data/media_repository_impl.dart';
import 'package:kiseki/features/media/domain/media_draft.dart';
import 'package:kiseki/features/media/domain/media_format.dart';
import 'package:kiseki/features/media/domain/media_query.dart';
import 'package:kiseki/features/media/domain/media_type.dart';
import 'package:kiseki/features/media/presentation/cubit/media_editor_cubit.dart';
import 'package:path/path.dart' as p;

/// Без нативного кодека: отдаёт фиктивные WebP-байты.
class _FakeProcessor implements ImageProcessor {
  @override
  Future<EncodedImage> process(String sourcePath) async =>
      EncodedImage(Uint8List.fromList([1, 2, 3]), Uint8List.fromList([4, 5, 6]));
}

/// Имитирует битый/нераспознанный файл — бросает типизированный сбой.
class _ThrowingProcessor implements ImageProcessor {
  @override
  Future<EncodedImage> process(String sourcePath) async =>
      throw const ImageDecodeFailure();
}

void main() {
  late AppDatabase db;
  late MediaRepositoryImpl repo;
  late TagRepositoryImpl tags;
  late ImageStorage images;
  late Directory tmpRoot;
  final now = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MediaRepositoryImpl(db, clock: () => now);
    tags = TagRepositoryImpl(db, clock: () => now);
    tmpRoot = Directory.systemTemp.createTempSync('kiseki_editor_test_');
    images = ImageStorage(MediaPaths(tmpRoot), _FakeProcessor());
  });
  tearDown(() async {
    await db.close();
    if (tmpRoot.existsSync()) tmpRoot.deleteSync(recursive: true);
  });

  MediaEditorCubit create() => MediaEditorCubit(repo, tags, images);
  MediaEditorCubit edit(String id) =>
      MediaEditorCubit(repo, tags, images, entryId: id);

  Future<dynamic> onlyEntry() async =>
      (await repo.watch(const MediaListQuery()).first).single;

  test('create: round-trips основные поля и поднимает justSaved', () async {
    final cubit = create();
    addTearDown(cubit.close);

    cubit.setFormat(MediaFormat.single);
    cubit.setMediaType(MediaType.movie);
    cubit.setTitle('Властелин колец');
    cubit.setRating(95);
    cubit.setYear(2001);
    await cubit.save();

    expect(cubit.state.justSaved, isTrue);
    final e = await onlyEntry();
    expect(e.title, 'Властелин колец');
    expect(e.mediaType, MediaType.movie);
    expect(e.format, MediaFormat.single);
    expect(e.rating?.value, 95);
    expect(e.year, 2001);
  });

  test('canSave требует формат, тип и непустое название', () async {
    final cubit = create();
    addTearDown(cubit.close);
    expect(cubit.state.canSave, isFalse);
    cubit.setTitle('Дюна');
    expect(cubit.state.canSave, isFalse, reason: 'нет формата и типа');
    cubit.setFormat(MediaFormat.single);
    expect(cubit.state.canSave, isFalse, reason: 'нет типа');
    cubit.setMediaType(MediaType.movie);
    expect(cubit.state.canSave, isTrue);
    cubit.setTitle('  ');
    expect(cubit.state.canSave, isFalse, reason: 'пустое название');
  });

  test('attachCover сохраняет обложку и пишет её в карточку', () async {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setFormat(MediaFormat.single);
    cubit.setMediaType(MediaType.movie);
    cubit.setTitle('С обложкой');

    final src = File(p.join(tmpRoot.path, 'src.jpg'))
      ..writeAsBytesSync([0, 1, 2, 3, 4]);
    await cubit.attachCover(src.path);
    expect(cubit.state.coverImageId, isNotNull);

    await cubit.save();
    final e = await onlyEntry();
    expect(e.cover?.id, cubit.state.coverImageId);
  });

  test('attachCover показывает типизированную ошибку обработки', () async {
    final failingImages = ImageStorage(MediaPaths(tmpRoot), _ThrowingProcessor());
    final cubit = MediaEditorCubit(repo, tags, failingImages);
    addTearDown(cubit.close);
    cubit.setTitle('Битая картинка');

    final src = File(p.join(tmpRoot.path, 'bad.jpg'))
      ..writeAsBytesSync([0, 1, 2]);
    await cubit.attachCover(src.path);

    expect(cubit.state.coverImageId, isNull);
    expect(cubit.state.processingImage, isFalse);
    expect(cubit.state.errorMessage, 'Не удалось обработать изображение');
  });

  test('формат выбирается независимо от вида (ADR-07)', () {
    final cubit = create();
    addTearDown(cubit.close);
    expect(cubit.state.format, isNull); // ничего не выбрано
    expect(cubit.state.mediaType, isNull);
    // Смена вида НЕ выставляет формат:
    cubit.setMediaType(MediaType.drama);
    expect(cubit.state.format, isNull, reason: 'вид не задаёт формат');
    // Формат выбирается явно:
    cubit.setFormat(MediaFormat.episodic);
    expect(cubit.state.format, MediaFormat.episodic);
    cubit.setMediaType(MediaType.anime);
    expect(cubit.state.format, MediaFormat.episodic,
        reason: 'смена вида не сбрасывает формат');
  });

  test('setRewatchCount меняет счётчик пересмотров и не уходит ниже 0', () {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setRewatchCount(3);
    expect(cubit.state.rewatchCount, 3);
    cubit.setRewatchCount(-5);
    expect(cubit.state.rewatchCount, 0);
  });

  test('серия без сезона нормализуется к S1 (CHECK)', () async {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setFormat(MediaFormat.episodic);
    cubit.setMediaType(MediaType.movie);
    cubit.setTitle('Лост');
    cubit.setCurrentEpisode(9);
    await cubit.save();

    final e = await onlyEntry();
    expect(e.currentSeason, 1);
    expect(e.currentEpisode, 9);
  });

  test('single зануляет сезонные поля при сохранении', () async {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setFormat(MediaFormat.episodic); // сначала серийный
    cubit.setMediaType(MediaType.anime);
    cubit.setTitle('Аниме-фильм');
    cubit.setCurrentSeason(2);
    cubit.setCurrentEpisode(5);
    cubit.setTotalEpisodes(12);
    cubit.setFormat(MediaFormat.single); // переключили на одиночный
    await cubit.save();

    final e = await onlyEntry();
    expect(e.format, MediaFormat.single);
    expect(e.currentSeason, isNull);
    expect(e.currentEpisode, isNull);
    expect(e.totalEpisodes, isNull);
  });

  test('причина снимается вне паузы/заброса', () async {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setFormat(MediaFormat.episodic);
    cubit.setMediaType(MediaType.drama);
    cubit.setTitle('Эйфория');
    cubit.setStatus(WatchStatus.paused);
    cubit.setUnfinishedReason(UnfinishedReason.noTime);
    cubit.setStatus(WatchStatus.watching); // уходим со статуса паузы
    expect(cubit.state.unfinishedReason, isNull);
    await cubit.save();
    expect((await onlyEntry()).unfinishedReason, isNull);
  });

  test('«жду серии» снимается при переходе на «заброшено»', () async {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setFormat(MediaFormat.episodic);
    cubit.setTitle('Атака титанов');
    cubit.setStatus(WatchStatus.paused);
    cubit.setUnfinishedReason(UnfinishedReason.waitingEpisodes);
    expect(cubit.state.canOfferWaiting, isTrue);
    cubit.setStatus(WatchStatus.dropped);
    expect(cubit.state.unfinishedReason, isNull);
  });

  test('dropped сохраняет валидную причину', () async {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setTitle('Сериал');
    cubit.setFormat(MediaFormat.episodic);
    cubit.setMediaType(MediaType.movie);
    cubit.setStatus(WatchStatus.dropped);
    cubit.setUnfinishedReason(UnfinishedReason.notForMe);
    await cubit.save();
    expect((await onlyEntry()).unfinishedReason, UnfinishedReason.notForMe);
  });

  test('addTag создаёт тег, выбирает его и пишет в карточку', () async {
    final cubit = create();
    addTearDown(cubit.close);
    cubit.setFormat(MediaFormat.single);
    cubit.setMediaType(MediaType.movie);
    cubit.setTitle('С тегом');
    await cubit.addTag('Драма');
    expect(cubit.state.selectedTagIds, hasLength(1));
    await cubit.save();

    final e = await onlyEntry();
    expect(e.tags.map((t) => t.name), ['Драма']);
  });

  test('edit: подгружает запись и сохраняет избранное/пересмотры', () async {
    final id = await repo.create(const MediaDraft(
      title: 'Во все тяжкие',
      mediaType: MediaType.movie,
      format: MediaFormat.episodic,
      status: WatchStatus.completed,
      isFavorite: true,
      rewatchCount: 2,
    ));

    final cubit = edit(id);
    addTearDown(cubit.close);
    await cubit.stream.firstWhere((s) => !s.loading);

    expect(cubit.state.title, 'Во все тяжкие');
    expect(cubit.state.isFavorite, isTrue);

    cubit.setTitle('Во все тяжкие (пересмотр)');
    await cubit.save();

    final e = await repo.findById(id);
    expect(e!.title, 'Во все тяжкие (пересмотр)');
    expect(e.isFavorite, isTrue, reason: 'избранное не должно сбрасываться');
    expect(e.rewatchCount, 2, reason: 'пересмотры не должны сбрасываться');
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/catalog_date.dart';
import 'package:kiseki/core/catalog/date_precision.dart';
import 'package:kiseki/core/database/app_database.dart';
import 'package:kiseki/features/vape/data/vape_repository_impl.dart';
import 'package:kiseki/features/vape/domain/flavor_category.dart';
import 'package:kiseki/features/vape/domain/nicotine_type.dart';
import 'package:kiseki/features/vape/domain/vape_draft.dart';
import 'package:kiseki/features/vape/domain/vape_repository.dart';

void main() {
  late AppDatabase db;
  late VapeRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = VapeRepositoryImpl(db);
  });
  tearDown(() async => db.close());

  test('create → watch round-trips все поля', () async {
    final id = await repo.create(VapeDraft(
      title: 'Манго-лёд',
      brand: 'BrandX',
      nicotineType: NicotineType.salt,
      nicotineStrength: '35-50',
      rating: 84,
      note: 'комментарий',
      addedAt: CatalogDate(DateTime.utc(2026, 6, 16), DatePrecision.day),
      flavorCategory: FlavorCategory.fruits,
      flavorDescription: 'манго с холодком',
      sweetness: 70,
      coolness: 90,
      richness: 60,
      canRebuy: true,
    ));
    expect(id, isNotEmpty);

    final list = await repo.watch().first;
    expect(list, hasLength(1));
    final e = list.first;
    expect(e.title, 'Манго-лёд');
    expect(e.brand, 'BrandX');
    expect(e.nicotineType, NicotineType.salt);
    expect(e.nicotineStrength, '35-50');
    expect(e.rating, 84);
    expect(e.note, 'комментарий');
    expect(e.flavorCategory, FlavorCategory.fruits);
    expect(e.flavorDescription, 'манго с холодком');
    expect(e.sweetness, 70);
    expect(e.coolness, 90);
    expect(e.richness, 60);
    expect(e.canRebuy, isTrue);
    expect(e.flavorFades, isFalse);
    expect(e.addedAt?.value.year, 2026);
    expect(e.addedAt?.value.month, 6);
  });

  test('update меняет поля', () async {
    final id = await repo.create(const VapeDraft(
      title: 'X',
      brand: 'B',
      nicotineType: NicotineType.hybrid,
      nicotineStrength: '6',
    ));
    await repo.update(
      id,
      const VapeDraft(
        title: 'Y',
        brand: 'B2',
        nicotineType: NicotineType.alkaline,
        nicotineStrength: '9',
        canRebuy: true,
      ),
    );
    final e = (await repo.watch().first).single;
    expect(e.title, 'Y');
    expect(e.brand, 'B2');
    expect(e.nicotineType, NicotineType.alkaline);
    expect(e.nicotineStrength, '9');
    expect(e.canRebuy, isTrue);
  });

  test('softDelete убирает из списка', () async {
    final id = await repo.create(const VapeDraft(
      title: 'X',
      brand: 'B',
      nicotineType: NicotineType.hybrid,
      nicotineStrength: '6',
    ));
    expect(await repo.watch().first, hasLength(1));
    await repo.softDelete(id);
    expect(await repo.watch().first, isEmpty);
  });
}

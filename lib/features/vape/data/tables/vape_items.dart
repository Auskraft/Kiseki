import 'package:drift/drift.dart';

import '../../../../core/database/tables/catalog_items.dart';
import '../vape_converters.dart';

/// Домен «жидкость для вейпа» — специализация 1:1 к ядру (PK = FK →
/// catalog_items.id, CASCADE). Общие поля (название вкуса=title, общая
/// оценка=rating, комментарий=note, дата добавления=started_at, фото=images) —
/// в ядре; здесь только вейп-специфика (ADR-02).
class VapeItems extends Table {
  @override
  String get tableName => 'vape_items';

  TextColumn get itemId =>
      text().references(CatalogItems, #id, onDelete: KeyAction.cascade)();

  /// Бренд (≤30) — обязателен.
  TextColumn get brand => text().withLength(min: 1, max: 30)();

  TextColumn get nicotineType => text().map(const NicotineTypeConverter())();

  /// Крепость (мг/мл) — значение из списка по типу; строка (есть диапазоны).
  TextColumn get nicotineStrength => text()();

  TextColumn get flavorCategory =>
      text().map(const FlavorCategoryConverter()).nullable()();

  /// Описание вкуса (≤150, валидация в UI).
  TextColumn get flavorDescription => text().nullable()();

  /// Уровни 0–100 (слайдер «оценки» /10): сладость / холодок / насыщенность.
  IntColumn get sweetness => integer().nullable()();
  IntColumn get coolness => integer().nullable()();
  IntColumn get richness => integer().nullable()();

  /// Можно покупать снова / мылится ли вкус.
  BoolColumn get canRebuy => boolean().withDefault(const Constant(false))();
  BoolColumn get flavorFades => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {itemId};
}

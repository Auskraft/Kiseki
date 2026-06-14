import 'package:drift/drift.dart';

import 'catalog_items.dart';
import 'tags.dart';

/// Связь M:N карточка <-> тег. Составной PK гарантирует уникальность пары;
/// оба FK с `ON DELETE CASCADE` (целостность — на уровне БД).
class ItemTags extends Table {
  @override
  String get tableName => 'item_tags';

  TextColumn get itemId =>
      text().references(CatalogItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}

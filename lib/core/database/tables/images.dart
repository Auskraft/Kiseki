import 'package:drift/drift.dart';

import '../converters.dart';
import 'catalog_items.dart';

/// Картинки записи — 1:N, общие для всех доменов (ADR-09).
/// Файлы хранятся в ФС как `<id>.webp`; в БД — только UUID. Обложка =
/// строка с `MIN(position)`. Row-класс — `ImageRow` (не конфликтует с
/// Flutter `Image`).
@DataClassName('ImageRow')
class Images extends Table {
  @override
  String get tableName => 'images';

  /// UUID картинки (имя файла).
  TextColumn get id => text()();

  TextColumn get itemId =>
      text().references(CatalogItems, #id, onDelete: KeyAction.cascade)();

  IntColumn get position => integer().withDefault(const Constant(0))();

  IntColumn get createdAt => integer().map(const DateTimeMsConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

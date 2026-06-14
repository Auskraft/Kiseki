import 'package:drift/drift.dart';

import '../converters.dart';

/// Общий справочник тегов (M:N через [ItemTags]). `nameNormalized` —
/// NFC -> lower -> trim, уникален (исключает визуальные дубликаты).
/// Row-класс назван `TagRow`, чтобы не конфликтовать с доменным `Tag`.
@DataClassName('TagRow')
class Tags extends Table {
  @override
  String get tableName => 'tags';

  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get nameNormalized => text()();

  TextColumn get color => text().nullable()();

  IntColumn get createdAt => integer().map(const DateTimeMsConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {nameNormalized},
      ];
}

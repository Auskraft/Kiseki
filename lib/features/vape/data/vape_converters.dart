import 'package:drift/drift.dart';

import '../domain/flavor_category.dart';
import '../domain/nicotine_type.dart';

class NicotineTypeConverter extends TypeConverter<NicotineType, String> {
  const NicotineTypeConverter();
  @override
  NicotineType fromSql(String fromDb) => NicotineType.fromCode(fromDb);
  @override
  String toSql(NicotineType value) => value.code;
}

class FlavorCategoryConverter extends TypeConverter<FlavorCategory, String> {
  const FlavorCategoryConverter();
  @override
  FlavorCategory fromSql(String fromDb) => FlavorCategory.fromCode(fromDb);
  @override
  String toSql(FlavorCategory value) => value.code;
}

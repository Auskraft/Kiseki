import 'package:drift/drift.dart';

import '../domain/media_format.dart';
import '../domain/media_type.dart';

class MediaTypeConverter extends TypeConverter<MediaType, String> {
  const MediaTypeConverter();
  @override
  MediaType fromSql(String fromDb) => MediaType.fromCode(fromDb);
  @override
  String toSql(MediaType value) => value.code;
}

class MediaFormatConverter extends TypeConverter<MediaFormat, String> {
  const MediaFormatConverter();
  @override
  MediaFormat fromSql(String fromDb) => MediaFormat.fromCode(fromDb);
  @override
  String toSql(MediaFormat value) => value.code;
}

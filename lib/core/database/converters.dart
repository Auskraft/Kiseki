import 'package:drift/drift.dart';

import '../catalog/catalog_domain.dart';
import '../catalog/date_precision.dart';
import '../catalog/unfinished_reason.dart';
import '../catalog/watch_status.dart';

/// `DateTime` <-> Unix-миллисекунды UTC (ADR-04). Все даты в БД — INTEGER ms.
class DateTimeMsConverter extends TypeConverter<DateTime, int> {
  const DateTimeMsConverter();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}

class WatchStatusConverter extends TypeConverter<WatchStatus, String> {
  const WatchStatusConverter();
  @override
  WatchStatus fromSql(String fromDb) => WatchStatus.fromCode(fromDb);
  @override
  String toSql(WatchStatus value) => value.code;
}

class UnfinishedReasonConverter extends TypeConverter<UnfinishedReason, String> {
  const UnfinishedReasonConverter();
  @override
  UnfinishedReason fromSql(String fromDb) => UnfinishedReason.fromCode(fromDb);
  @override
  String toSql(UnfinishedReason value) => value.code;
}

class CatalogDomainConverter extends TypeConverter<CatalogDomain, String> {
  const CatalogDomainConverter();
  @override
  CatalogDomain fromSql(String fromDb) => CatalogDomain.fromCode(fromDb);
  @override
  String toSql(CatalogDomain value) => value.code;
}

class DatePrecisionConverter extends TypeConverter<DatePrecision, String> {
  const DatePrecisionConverter();
  @override
  DatePrecision fromSql(String fromDb) => DatePrecision.fromCode(fromDb);
  @override
  String toSql(DatePrecision value) => value.code;
}

import 'package:equatable/equatable.dart';

import 'date_precision.dart';

/// Пользовательская дата + её точность (день/месяц/год). Позволяет хранить
/// ориентировочные даты без потери сортируемости (TECH_DESIGN §6.6).
class CatalogDate extends Equatable {
  const CatalogDate(this.value, [this.precision = DatePrecision.day]);

  final DateTime value;
  final DatePrecision precision;

  @override
  List<Object?> get props => [value, precision];
}

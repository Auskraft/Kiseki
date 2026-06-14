/// Форматирование/нормализация пользовательских дат (TECH_DESIGN §6.6).
/// Русские названия месяцев — вручную, без intl-locale-init.
library;

import '../catalog/catalog_date.dart';
import '../catalog/date_precision.dart';

const _monthsNom = <String>[
  'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
  'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь',
];

/// Человекочитаемая дата по её точности:
/// `day` → «12.03.2024», `month` → «март 2024», `year` → «2024».
String formatCatalogDate(CatalogDate date) {
  final d = date.value;
  return switch (date.precision) {
    DatePrecision.day => '${_two(d.day)}.${_two(d.month)}.${d.year}',
    DatePrecision.month => '${_monthsNom[d.month - 1]} ${d.year}',
    DatePrecision.year => '${d.year}',
  };
}

/// Нормализует дату к точности: год → 1 января, месяц → 1-е число (§6.6).
/// Хранится в UTC (модель — Unix-мс UTC).
CatalogDate normalizeCatalogDate(DateTime d, DatePrecision p) {
  return switch (p) {
    DatePrecision.day => CatalogDate(DateTime.utc(d.year, d.month, d.day), p),
    DatePrecision.month => CatalogDate(DateTime.utc(d.year, d.month), p),
    DatePrecision.year => CatalogDate(DateTime.utc(d.year), p),
  };
}

String _two(int v) => v.toString().padLeft(2, '0');

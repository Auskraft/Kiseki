import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/catalog/catalog_date.dart';
import 'package:kiseki/core/catalog/date_precision.dart';
import 'package:kiseki/features/media/presentation/widgets/editor/catalog_date_field.dart';

void main() {
  test('formatCatalogDate форматирует по точности', () {
    final d = DateTime.utc(2024, 3, 5);
    expect(
      formatCatalogDate(CatalogDate(d, DatePrecision.day)),
      '05.03.2024',
    );
    expect(
      formatCatalogDate(CatalogDate(d, DatePrecision.month)),
      'март 2024',
    );
    expect(
      formatCatalogDate(CatalogDate(d, DatePrecision.year)),
      '2024',
    );
  });

  test('normalizeCatalogDate усекает по точности и держит UTC', () {
    final src = DateTime(2024, 7, 23, 14, 30); // local, с временем

    final day = normalizeCatalogDate(src, DatePrecision.day);
    expect(day.value, DateTime.utc(2024, 7, 23));
    expect(day.value.isUtc, isTrue);

    final month = normalizeCatalogDate(src, DatePrecision.month);
    expect(month.value, DateTime.utc(2024, 7, 1));

    final year = normalizeCatalogDate(src, DatePrecision.year);
    expect(year.value, DateTime.utc(2024, 1, 1));
  });
}

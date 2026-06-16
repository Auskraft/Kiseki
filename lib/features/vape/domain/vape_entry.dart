import 'package:equatable/equatable.dart';

import '../../../core/catalog/catalog_date.dart';
import '../../../core/catalog/catalog_image.dart';
import 'flavor_category.dart';
import 'nicotine_type.dart';

/// Доменная модель жидкости для вейпа (read-модель, отделена от Drift-строк).
/// Общие поля — из ядра (`title` = название вкуса, `rating` = общая оценка,
/// `note` = комментарий, `addedAt` = дата добавления, `images` = фото).
class VapeEntry extends Equatable {
  const VapeEntry({
    required this.id,
    required this.title,
    required this.brand,
    required this.nicotineType,
    required this.nicotineStrength,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.note,
    this.addedAt,
    this.flavorCategory,
    this.flavorDescription,
    this.sweetness,
    this.coolness,
    this.richness,
    this.canRebuy = false,
    this.flavorFades = false,
    this.damagesHardware = false,
    this.images = const [],
    this.deletedAt,
  });

  final String id;

  /// Название вкуса (ядро `title`).
  final String title;
  final String brand;
  final NicotineType nicotineType;
  final String nicotineStrength;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Общая оценка вкуса 0–100 (ядро `rating`); `null` — без оценки.
  final int? rating;

  /// Комментарий (ядро `note`).
  final String? note;

  /// Дата добавления (ядро `started_at`, точность «день»).
  final CatalogDate? addedAt;

  final FlavorCategory? flavorCategory;
  final String? flavorDescription;

  /// Уровни 0–100: сладость / холодок / насыщенность.
  final int? sweetness;
  final int? coolness;
  final int? richness;

  final bool canRebuy;
  final bool flavorFades;

  /// Портит «железо» (вату/картридж/испаритель).
  final bool damagesHardware;

  final List<CatalogImage> images;
  final DateTime? deletedAt;

  /// Фото упаковки = картинка с наименьшим `position` (или `null`).
  CatalogImage? get cover {
    if (images.isEmpty) return null;
    final sorted = [...images]..sort((a, b) => a.position.compareTo(b.position));
    return sorted.first;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        brand,
        nicotineType,
        nicotineStrength,
        createdAt,
        updatedAt,
        rating,
        note,
        addedAt,
        flavorCategory,
        flavorDescription,
        sweetness,
        coolness,
        richness,
        canRebuy,
        flavorFades,
        damagesHardware,
        images,
        deletedAt,
      ];
}

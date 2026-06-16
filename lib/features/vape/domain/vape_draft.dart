import '../../../core/catalog/catalog_date.dart';
import 'flavor_category.dart';
import 'nicotine_type.dart';

/// Входная модель создания/редактирования жидкости (без id и служебных дат —
/// их назначает репозиторий).
class VapeDraft {
  const VapeDraft({
    required this.title,
    required this.brand,
    required this.nicotineType,
    required this.nicotineStrength,
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
    this.coverImageId,
  });

  final String title;
  final String brand;
  final NicotineType nicotineType;
  final String nicotineStrength;
  final int? rating;
  final String? note;
  final CatalogDate? addedAt;
  final FlavorCategory? flavorCategory;
  final String? flavorDescription;
  final int? sweetness;
  final int? coolness;
  final int? richness;
  final bool canRebuy;
  final bool flavorFades;
  final bool damagesHardware;

  /// UUID фото упаковки (файлы уже сохранены [ImageStorage]). `null` — без фото.
  final String? coverImageId;
}

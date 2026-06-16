import 'nicotine_type.dart';

/// Варианты крепости (мг/мл) по типу никотина — справочные const-данные (как
/// `kMediaGenres`, без таблицы в БД). Есть диапазоны (напр. «1,5-3»), поэтому
/// хранится строкой: пользователь выбирает значение из списка своего типа.
const Map<NicotineType, List<String>> kNicotineStrengths = {
  NicotineType.salt: ['0', '5', '10', '12', '20', '25', '30'],
  NicotineType.alkaline: ['0', '1,5-3', '6', '9', '12', '18'],
  NicotineType.hybrid: ['0', '3', '6', '10', '12', '20'],
};

List<String> nicotineStrengthsFor(NicotineType type) =>
    kNicotineStrengths[type] ?? const [];

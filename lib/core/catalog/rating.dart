import 'package:equatable/equatable.dart';

/// Оценка по 100-балльной шкале (0–100). Хранение отвязано от представления:
/// в БД лежит `int`, а UI может показывать как 0–100, /10 или звёзды
/// (TECH_DESIGN §6.4). `null`-оценка («не оценено») моделируется отсутствием
/// объекта `Rating?`, а НЕ значением 0.
class Rating extends Equatable {
  const Rating(this.value)
      : assert(value >= 0 && value <= 100, 'rating must be 0..100');

  /// Безопасное создание из значения БД: зажимает в диапазон 0..100.
  factory Rating.clamp(int raw) => Rating(raw.clamp(0, 100));

  final int value;

  /// Альтернативное представление в 10-балльной шкале: 84 -> 8.4.
  double get asTenScale => value / 10.0;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '$value';
}

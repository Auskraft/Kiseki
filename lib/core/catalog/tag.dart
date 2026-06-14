import 'package:equatable/equatable.dart';

/// Тег картотеки (общий для всех доменов).
class Tag extends Equatable {
  const Tag({required this.id, required this.name, this.color});

  final String id;
  final String name;

  /// HEX-цвет для UI, напр. `#FFAA00` (опционально).
  final String? color;

  @override
  List<Object?> get props => [id, name, color];
}

/// Тег + число живых карточек с ним (для экрана управления тегами).
class TagWithCount extends Equatable {
  const TagWithCount(this.tag, this.count);

  final Tag tag;
  final int count;

  @override
  List<Object?> get props => [tag, count];
}

import 'package:equatable/equatable.dart';

/// Ссылка на картинку записи (1:N, ADR-09). `id` — UUID картинки, по нему
/// строятся пути файлов `media/full|thumb/<id>.webp`. Обложка карточки —
/// картинка с наименьшим [position].
class CatalogImage extends Equatable {
  const CatalogImage({required this.id, required this.position});

  final String id;
  final int position;

  @override
  List<Object?> get props => [id, position];
}

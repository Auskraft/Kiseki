import 'package:flutter/painting.dart';

/// Парсит HEX-строку тега (`#RRGGBB` или `RRGGBB`) в [Color]. Возвращает
/// `null`, если строка пустая/некорректная (вызывающий ставит фолбэк-цвет).
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  var h = hex.replaceFirst('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

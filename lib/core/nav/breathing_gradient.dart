import 'package:flutter/material.dart';

/// Период «дыхания» (мс). Фаза берётся от стенных часов, поэтому непрерывна между
/// пересозданиями виджета (смена вкладки/перестроение).
const int _periodMs = 16000;

/// Анимированный «дышащий» цветовой градиент из акцентов темы. Общий для активной
/// капсулы нав-бара и FAB. Заполняет себя; внутри RepaintBoundary — вечная
/// 60-fps перерисовка изолирована и не поднимается выше (стекло бара / тело экрана
/// / список под FAB не перерисовываются).
class BreathingGradient extends StatefulWidget {
  const BreathingGradient({super.key, required this.colors});

  /// Зацикленные цвета (последний = первый для бесшовности), напр.
  /// `[primary, mid, secondary, primary]`.
  final List<Color> colors;

  @override
  State<BreathingGradient> createState() => _BreathingGradientState();
}

class _BreathingGradientState extends State<BreathingGradient>
    with SingleTickerProviderStateMixin {
  // Тикер лишь будит перерисовку; фаза — от стенных часов (непрерывна).
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _periodMs),
  )..repeat();

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, _) {
          final phase =
              (DateTime.now().millisecondsSinceEpoch % _periodMs) / _periodMs;
          final t = phase < 0.5 ? phase * 2 : 2 - phase * 2; // треугольник 0→1→0
          return CustomPaint(
            painter: _BreathingPainter(t, widget.colors),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

/// Скользящий градиент: зацикленные цвета + оверсайз-шейдер (рект шире области),
/// поэтому «течение» без жёсткого края и тёмной складки.
class _BreathingPainter extends CustomPainter {
  _BreathingPainter(this.t, this.colors);

  final double t; // 0..1, треугольник «дыхания»
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = size.width * 2 * t;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: [
        for (var i = 0; i < colors.length; i++) i / (colors.length - 1),
      ],
      transform: _Slide(dx),
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(-size.width * 1.5, 0, size.width * 4, size.height),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_BreathingPainter old) =>
      old.t != t || old.colors != colors;
}

class _Slide extends GradientTransform {
  const _Slide(this.dx);
  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// Стандартный набор «дышащих» цветов из акцентов темы (зациклен) — единый для
/// капсулы и FAB. Вызывать как `breathingColors(tk.primary, tk.secondary)`.
List<Color> breathingColors(Color primary, Color secondary) => <Color>[
      primary,
      Color.lerp(primary, secondary, 0.45)!,
      secondary,
      primary,
    ];

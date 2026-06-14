import 'package:flutter/material.dart';

import '../catalog/watch_status.dart';

/// Семантические токены темы (поверх Material 3 `ColorScheme`).
/// Виджеты читают значения ТОЛЬКО отсюда (или из `colorScheme`) — никакого
/// хардкода цветов. Доступ: `context.tokens` (см. theme_context.dart).
@immutable
class KisekiTokens extends ThemeExtension<KisekiTokens> {
  const KisekiTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.onBg,
    required this.onMuted,
    required this.onFaint,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.outline,
    required this.outlineSoft,
    required this.success,
    required this.warning,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.favorite,
    required this.scoreRamp,
    required this.statusColors,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color onBg;
  final Color onMuted;
  final Color onFaint;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color outline;
  final Color outlineSoft;
  final Color success;
  final Color warning;
  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;

  /// Цвет «избранного» (сердечко) на поверхности — не только над постером.
  final Color favorite;

  /// Шкала оценки 0–100 (cold→warm), 5 ступеней.
  final List<Color> scoreRamp;

  /// Цвет статуса просмотра.
  final Map<WatchStatus, Color> statusColors;

  /// Тинт-контейнер: `mix(accent 16%, surface)` (для чипов статусов/тегов).
  Color tint(Color accent, [double amount = 0.16]) =>
      Color.alphaBlend(accent.withValues(alpha: amount), surface);

  /// Цвет оценки по диапазону (число всегда дублируется текстом!).
  Color scoreColor(int value) {
    if (value < 40) return scoreRamp[0];
    if (value < 60) return scoreRamp[1];
    if (value < 75) return scoreRamp[2];
    if (value < 90) return scoreRamp[3];
    return scoreRamp[4];
  }

  Color statusColor(WatchStatus status) =>
      statusColors[status] ?? statusColors[WatchStatus.plan]!;

  @override
  KisekiTokens copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? onBg,
    Color? onMuted,
    Color? onFaint,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? outline,
    Color? outlineSoft,
    Color? success,
    Color? warning,
    Color? error,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? favorite,
    List<Color>? scoreRamp,
    Map<WatchStatus, Color>? statusColors,
  }) {
    return KisekiTokens(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      onBg: onBg ?? this.onBg,
      onMuted: onMuted ?? this.onMuted,
      onFaint: onFaint ?? this.onFaint,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      outline: outline ?? this.outline,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      favorite: favorite ?? this.favorite,
      scoreRamp: scoreRamp ?? this.scoreRamp,
      statusColors: statusColors ?? this.statusColors,
    );
  }

  @override
  KisekiTokens lerp(ThemeExtension<KisekiTokens>? other, double t) {
    if (other is! KisekiTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return KisekiTokens(
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      surface2: c(surface2, other.surface2),
      surface3: c(surface3, other.surface3),
      onBg: c(onBg, other.onBg),
      onMuted: c(onMuted, other.onMuted),
      onFaint: c(onFaint, other.onFaint),
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      primaryContainer: c(primaryContainer, other.primaryContainer),
      onPrimaryContainer: c(onPrimaryContainer, other.onPrimaryContainer),
      secondary: c(secondary, other.secondary),
      outline: c(outline, other.outline),
      outlineSoft: c(outlineSoft, other.outlineSoft),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      error: c(error, other.error),
      errorContainer: c(errorContainer, other.errorContainer),
      onErrorContainer: c(onErrorContainer, other.onErrorContainer),
      favorite: c(favorite, other.favorite),
      scoreRamp: [
        for (var i = 0; i < scoreRamp.length; i++)
          c(scoreRamp[i], other.scoreRamp[i]),
      ],
      statusColors: {
        for (final key in statusColors.keys)
          key: c(statusColors[key]!, other.statusColors[key] ?? statusColors[key]!),
      },
    );
  }
}

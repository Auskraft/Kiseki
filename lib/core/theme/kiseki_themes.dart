import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../catalog/watch_status.dart';
import 'app_dimens.dart';
import 'kiseki_theme_id.dart';
import 'kiseki_tokens.dart';

/// Цветовые данные тем (из дизайн-хэндоффа). Тема-специфичны 14 поверхностей;
/// сигналы/шкала оценки/статусы общие на режим (light/dark) для всех тем.

@immutable
class _Palette {
  const _Palette({
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
  });

  final Color bg, surface, surface2, surface3;
  final Color onBg, onMuted, onFaint;
  final Color primary, onPrimary, primaryContainer, onPrimaryContainer;
  final Color secondary, outline, outlineSoft;
}

// ── Общие на режим (наследуются всеми темами) ──
const _signalsLight = (
  success: Color(0xFF4F8A5B),
  warning: Color(0xFFB07F2C),
  error: Color(0xFFC0493B),
  errorContainer: Color(0xFFF7D9D4),
  onErrorContainer: Color(0xFF511712),
  favorite: Color(0xFFE0608A),
);
const _signalsDark = (
  success: Color(0xFF7FBE86),
  warning: Color(0xFFE0B36A),
  error: Color(0xFFE48A7E),
  errorContainer: Color(0xFF5A211A),
  onErrorContainer: Color(0xFFF7D9D4),
  favorite: Color(0xFFFF7BA3),
);

const _scoreLight = <Color>[
  Color(0xFF5E78C9),
  Color(0xFF3F9FA6),
  Color(0xFF6FA64F),
  Color(0xFFD79A3C),
  Color(0xFFE2683E),
];
const _scoreDark = <Color>[
  Color(0xFF8090DB),
  Color(0xFF5BBEC4),
  Color(0xFF8FC56F),
  Color(0xFFE6B45C),
  Color(0xFFF0855C),
];

const _statusLight = <WatchStatus, Color>{
  WatchStatus.plan: Color(0xFF6B7BC9),
  WatchStatus.watching: Color(0xFFC76B4E),
  WatchStatus.completed: Color(0xFF4F9A5E),
  WatchStatus.paused: Color(0xFFD2952F),
  WatchStatus.dropped: Color(0xFF978B80),
};
const _statusDark = <WatchStatus, Color>{
  WatchStatus.plan: Color(0xFF8B99E0),
  WatchStatus.watching: Color(0xFFE08A6E),
  WatchStatus.completed: Color(0xFF74C081),
  WatchStatus.paused: Color(0xFFE6B85F),
  WatchStatus.dropped: Color(0xFFA99E92),
};

// ── Палитры тем ──
const _baseLight = _Palette(
  bg: Color(0xFFF4F1EC), surface: Color(0xFFFBF9F5), surface2: Color(0xFFFFFFFF), surface3: Color(0xFFEEEAE2),
  onBg: Color(0xFF231E1A), onMuted: Color(0xFF6E655B), onFaint: Color(0xFF9C9288),
  primary: Color(0xFFBE5D49), onPrimary: Color(0xFFFFFFFF), primaryContainer: Color(0xFFF6DCD2), onPrimaryContainer: Color(0xFF48190F),
  secondary: Color(0xFF5E7A6F), outline: Color(0xFFD9D1C6), outlineSoft: Color(0xFFE8E1D7),
);
const _baseDark = _Palette(
  bg: Color(0xFF15110F), surface: Color(0xFF1E1A17), surface2: Color(0xFF262220), surface3: Color(0xFF2F2A26),
  onBg: Color(0xFFECE6DE), onMuted: Color(0xFFB0A79C), onFaint: Color(0xFF7E766D),
  primary: Color(0xFFE2876E), onPrimary: Color(0xFF3A1408), primaryContainer: Color(0xFF5A2A1C), onPrimaryContainer: Color(0xFFF6DCD2),
  secondary: Color(0xFF93B0A3), outline: Color(0xFF39322D), outlineSoft: Color(0xFF2B2622),
);
const _sakuraLight = _Palette(
  bg: Color(0xFFFBF0F1), surface: Color(0xFFFFF7F8), surface2: Color(0xFFFFFFFF), surface3: Color(0xFFF6E2E6),
  onBg: Color(0xFF2E1F26), onMuted: Color(0xFF7A5A66), onFaint: Color(0xFFB79AA4),
  primary: Color(0xFFD06A86), onPrimary: Color(0xFFFFFFFF), primaryContainer: Color(0xFFFAD9E1), onPrimaryContainer: Color(0xFF4A1426),
  secondary: Color(0xFF8A6E9E), outline: Color(0xFFEBD0D7), outlineSoft: Color(0xFFF3E0E5),
);
const _sakuraDark = _Palette(
  bg: Color(0xFF1A1014), surface: Color(0xFF251820), surface2: Color(0xFF2E1F28), surface3: Color(0xFF36242E),
  onBg: Color(0xFFF3E2E8), onMuted: Color(0xFFC39FAC), onFaint: Color(0xFF8A6E78),
  primary: Color(0xFFED8AA3), onPrimary: Color(0xFF3E0E1E), primaryContainer: Color(0xFF5A2336), onPrimaryContainer: Color(0xFFFAD9E1),
  secondary: Color(0xFFBFA0CE), outline: Color(0xFF3C2A33), outlineSoft: Color(0xFF2C1F27),
);
const _matchaLight = _Palette(
  bg: Color(0xFFEEF2E9), surface: Color(0xFFF7FAF2), surface2: Color(0xFFFFFFFF), surface3: Color(0xFFE1E9D7),
  onBg: Color(0xFF1F271C), onMuted: Color(0xFF5E6B55), onFaint: Color(0xFF94A088),
  primary: Color(0xFF5E8C4F), onPrimary: Color(0xFFFFFFFF), primaryContainer: Color(0xFFD8E8C8), onPrimaryContainer: Color(0xFF1B2E12),
  secondary: Color(0xFF4F8A86), outline: Color(0xFFD3DEC6), outlineSoft: Color(0xFFE3EAD8),
);
const _matchaDark = _Palette(
  bg: Color(0xFF11140F), surface: Color(0xFF1A1F16), surface2: Color(0xFF222820), surface3: Color(0xFF2A3126),
  onBg: Color(0xFFE6EEDD), onMuted: Color(0xFFA6B399), onFaint: Color(0xFF76836A),
  primary: Color(0xFF9FC97F), onPrimary: Color(0xFF16280C), primaryContainer: Color(0xFF33471F), onPrimaryContainer: Color(0xFFD8E8C8),
  secondary: Color(0xFF8FC2BC), outline: Color(0xFF313A2A), outlineSoft: Color(0xFF232A1E),
);
const _midnightLight = _Palette(
  bg: Color(0xFFEEF0FA), surface: Color(0xFFF7F8FE), surface2: Color(0xFFFFFFFF), surface3: Color(0xFFE2E5F4),
  onBg: Color(0xFF1C1E33), onMuted: Color(0xFF565A7A), onFaint: Color(0xFF9094B4),
  primary: Color(0xFF5560D6), onPrimary: Color(0xFFFFFFFF), primaryContainer: Color(0xFFDCDFF8), onPrimaryContainer: Color(0xFF161A4A),
  secondary: Color(0xFF7E5AB0), outline: Color(0xFFD2D5EC), outlineSoft: Color(0xFFE4E6F5),
);
const _midnightDark = _Palette(
  bg: Color(0xFF0E0F1C), surface: Color(0xFF171A2C), surface2: Color(0xFF1F2238), surface3: Color(0xFF282C46),
  onBg: Color(0xFFE4E6F5), onMuted: Color(0xFF9EA2C4), onFaint: Color(0xFF6E7298),
  primary: Color(0xFF8C95F0), onPrimary: Color(0xFF15184A), primaryContainer: Color(0xFF2E3470), onPrimaryContainer: Color(0xFFDCDFF8),
  secondary: Color(0xFFA98FE0), outline: Color(0xFF2E3354), outlineSoft: Color(0xFF1E2138),
);
const _sunsetLight = _Palette(
  bg: Color(0xFFFBF1E8), surface: Color(0xFFFFF8F1), surface2: Color(0xFFFFFFFF), surface3: Color(0xFFF6E2D0),
  onBg: Color(0xFF2E2018), onMuted: Color(0xFF7A6353), onFaint: Color(0xFFB89A82),
  primary: Color(0xFFD07A3C), onPrimary: Color(0xFFFFFFFF), primaryContainer: Color(0xFFFBDFC4), onPrimaryContainer: Color(0xFF4A2710),
  secondary: Color(0xFFB5564A), outline: Color(0xFFEBD7C4), outlineSoft: Color(0xFFF4E6D7),
);
const _sunsetDark = _Palette(
  bg: Color(0xFF1A1310), surface: Color(0xFF241A14), surface2: Color(0xFF2E2219), surface3: Color(0xFF382A1F),
  onBg: Color(0xFFF3E5D8), onMuted: Color(0xFFC3A88F), onFaint: Color(0xFF8A745F),
  primary: Color(0xFFF0A055), onPrimary: Color(0xFF3E2008), primaryContainer: Color(0xFF5A3520), onPrimaryContainer: Color(0xFFFBDFC4),
  secondary: Color(0xFFE8897C), outline: Color(0xFF3C2C20), outlineSoft: Color(0xFF2A1F17),
);

/// Выводит полную палитру (14 поверхностей) из акцента [primary] + [secondary]
/// для (дополнительных) тем — чтобы добавлять темы дёшево, без ручной настройки
/// каждой поверхности. Базовые 5 тем хэндоффа заданы вручную выше и через
/// `_derive` НЕ проходят. Светлые/тёмные ступени и контуры тонируются в тон
/// акцента (HSL), контраст onPrimary берётся по яркости акцента.
_Palette _derive(Color primary, Color secondary, Brightness b) {
  final hp = HSLColor.fromColor(primary);
  final h = hp.hue;
  final s = hp.saturation;
  Color c(double sat, double light) =>
      HSLColor.fromAHSL(1, h, sat.clamp(0.0, 1.0), light.clamp(0.0, 1.0))
          .toColor();
  final onP = ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF201A17);

  if (b == Brightness.light) {
    return _Palette(
      bg: c(s * 0.5, 0.955),
      surface: c(s * 0.34, 0.978),
      surface2: const Color(0xFFFFFFFF),
      surface3: c(s * 0.45, 0.915),
      onBg: c(0.26, 0.13),
      onMuted: c(0.15, 0.40),
      onFaint: c(0.13, 0.60),
      primary: primary,
      onPrimary: onP,
      primaryContainer: c(s * 0.55, 0.88),
      onPrimaryContainer: c(0.55, 0.20),
      secondary: secondary,
      outline: c(0.16, 0.84),
      outlineSoft: c(0.14, 0.905),
    );
  }
  final darkPrimary = hp
      .withLightness((hp.lightness + 0.12).clamp(0.0, 0.72))
      .withSaturation((hp.saturation * 0.95).clamp(0.0, 1.0))
      .toColor();
  final hs = HSLColor.fromColor(secondary);
  final darkSecondary =
      hs.withLightness((hs.lightness + 0.12).clamp(0.0, 0.74)).toColor();
  final onDP =
      ThemeData.estimateBrightnessForColor(darkPrimary) == Brightness.dark
          ? const Color(0xFFFFFFFF)
          : c(0.6, 0.12);
  return _Palette(
    bg: c(0.30, 0.065),
    surface: c(0.26, 0.105),
    surface2: c(0.24, 0.135),
    surface3: c(0.21, 0.17),
    onBg: c(0.14, 0.92),
    onMuted: c(0.13, 0.69),
    onFaint: c(0.12, 0.47),
    primary: darkPrimary,
    onPrimary: onDP,
    primaryContainer: c(0.40, 0.26),
    onPrimaryContainer: c(0.45, 0.86),
    secondary: darkSecondary,
    outline: c(0.17, 0.24),
    outlineSoft: c(0.19, 0.155),
  );
}

({_Palette light, _Palette dark}) _seed(Color primary, Color secondary) => (
      light: _derive(primary, secondary, Brightness.light),
      dark: _derive(primary, secondary, Brightness.dark),
    );

final Map<KisekiThemeId, ({_Palette light, _Palette dark})> _palettes = {
  KisekiThemeId.base: (light: _baseLight, dark: _baseDark),
  KisekiThemeId.sakura: (light: _sakuraLight, dark: _sakuraDark),
  KisekiThemeId.matcha: (light: _matchaLight, dark: _matchaDark),
  KisekiThemeId.midnight: (light: _midnightLight, dark: _midnightDark),
  KisekiThemeId.sunset: (light: _sunsetLight, dark: _sunsetDark),
  // Дополнительные темы (выведены из акцента; вдохновлены палитрой «дневника
  // давления»). Тонкая ручная доводка — по визуальной проверке владельца.
  KisekiThemeId.ocean: _seed(const Color(0xFF0E8C8C), const Color(0xFF3B73C4)),
  KisekiThemeId.lavender:
      _seed(const Color(0xFF8B5CF6), const Color(0xFFB07FD8)),
  KisekiThemeId.cherry: _seed(const Color(0xFFCB3A57), const Color(0xFFA8557A)),
  KisekiThemeId.amber: _seed(const Color(0xFFC8941A), const Color(0xFFB5654A)),
  KisekiThemeId.sky: _seed(const Color(0xFF2E90D9), const Color(0xFF4FB0A8)),
  KisekiThemeId.ink: _seed(const Color(0xFF566079), const Color(0xFF6E7A94)),
};

/// Семантические токены для (тема, режим).
KisekiTokens tokensFor(KisekiThemeId id, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final p = dark ? _palettes[id]!.dark : _palettes[id]!.light;
  final sig = dark ? _signalsDark : _signalsLight;
  return KisekiTokens(
    bg: p.bg,
    surface: p.surface,
    surface2: p.surface2,
    surface3: p.surface3,
    onBg: p.onBg,
    onMuted: p.onMuted,
    onFaint: p.onFaint,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.primaryContainer,
    onPrimaryContainer: p.onPrimaryContainer,
    secondary: p.secondary,
    outline: p.outline,
    outlineSoft: p.outlineSoft,
    success: sig.success,
    warning: sig.warning,
    error: sig.error,
    errorContainer: sig.errorContainer,
    onErrorContainer: sig.onErrorContainer,
    favorite: sig.favorite,
    scoreRamp: dark ? _scoreDark : _scoreLight,
    statusColors: dark ? _statusDark : _statusLight,
  );
}

/// Свотч-цвет темы для пикера (берём primary тёмного режима — насыщеннее).
Color themeSwatch(KisekiThemeId id) => _palettes[id]!.dark.primary;

/// Готовый `ThemeData` для (тема, режим): M3 ColorScheme + KisekiTokens +
/// типографика Onest/Unbounded (с уменьшающим [uiScale]).
ThemeData buildKisekiTheme(KisekiThemeId id, Brightness brightness) {
  final t = tokensFor(id, brightness);
  final scheme = ColorScheme.fromSeed(
    seedColor: t.primary,
    brightness: brightness,
  ).copyWith(
    primary: t.primary,
    onPrimary: t.onPrimary,
    primaryContainer: t.primaryContainer,
    onPrimaryContainer: t.onPrimaryContainer,
    secondary: t.secondary,
    error: t.error,
    errorContainer: t.errorContainer,
    onErrorContainer: t.onErrorContainer,
    surface: t.surface,
    onSurface: t.onBg,
    surfaceContainerHighest: t.surface3,
    onSurfaceVariant: t.onMuted,
    outline: t.outline,
    outlineVariant: t.outlineSoft,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    textTheme: _textTheme(t),
    extensions: [t],
    splashColor: t.primary.withValues(alpha: 0.10),
    highlightColor: t.primary.withValues(alpha: 0.06),
  );
}

TextTheme _textTheme(KisekiTokens t) {
  final c = t.onBg;
  final muted = t.onMuted;

  // Заголовки — Unbounded (бандл, variable-weight; офлайн, не из сети).
  TextStyle heading(double size, {double wght = 600, Color? color, double? height}) =>
      TextStyle(
        fontFamily: 'Unbounded',
        fontVariations: [FontVariation('wght', wght)],
        fontSize: size * uiScale,
        color: color ?? c,
        height: height,
        letterSpacing: -0.2,
      );
  TextStyle onest(double size,
          {FontWeight w = FontWeight.w400, Color? color, double? height}) =>
      GoogleFonts.onest(
        fontSize: size * uiScale,
        fontWeight: w,
        color: color ?? c,
        height: height,
      );

  return TextTheme(
    displaySmall: heading(22, height: 1.12), // заголовки экранов (Картотека)
    headlineSmall: heading(18, height: 1.15),
    titleLarge: heading(19, height: 1.15), // название медиа в детали
    titleMedium: heading(14.5, height: 1.2), // заголовки разделов (полки, «Все карточки»)
    titleSmall: onest(13, w: FontWeight.w600),
    bodyLarge: onest(15, height: 1.45),
    bodyMedium: onest(13.5, height: 1.5, color: muted),
    bodySmall: onest(11.5, color: muted),
    labelLarge: onest(12.5, w: FontWeight.w600),
    labelMedium: onest(11.5, w: FontWeight.w600, color: muted),
    labelSmall: onest(11, w: FontWeight.w600, color: muted),
  );
}

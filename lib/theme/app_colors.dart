import 'package:flutter/material.dart';

import 'app_styles.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryStrong,
    required this.primarySoft,
    required this.secondary,
    required this.background,
    required this.backgroundTinted,
    required this.card,
    required this.raised,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.label,
    required this.cardBorder,
    required this.divider,
    required this.lavenderSurface,
    required this.lavenderBorder,
    required this.mutedSurface,
    required this.progressTrack,
    required this.danger,
    required this.dangerSurface,
    required this.dangerBorder,
    required this.favorite,
    required this.memoryLevelColors,
    required this.topicBackgrounds,
    required this.topicForegrounds,
  });

  static const light = AppPalette(
    primary: Color(0xFF7155C8),
    onPrimary: Color(0xFFFFFFFF),
    primaryStrong: Color(0xFF4A3A85),
    primarySoft: Color(0xFF9B7FDC),
    secondary: Color(0xFFEDE6FA),
    background: Color(0xFFFFFFFF),
    backgroundTinted: Color(0xFFF6F2FC),
    card: Color(0xFFFFFFFF),
    raised: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1F1B2E),
    textSecondary: Color(0xFF6B6580),
    textMuted: Color(0xFF9A93AD),
    label: Color(0xFF7D6F9E),
    cardBorder: Color(0xFFEAE6F2),
    divider: Color(0xFFEFECF5),
    lavenderSurface: Color(0xFFF2ECFB),
    lavenderBorder: Color(0xFFE2D8F5),
    mutedSurface: Color(0xFFF5F3F9),
    progressTrack: Color(0xFFECE9F2),
    danger: Color(0xFF9C5868),
    dangerSurface: Color(0xFFFDF3F5),
    dangerBorder: Color(0xFFF4D8DE),
    favorite: Color(0xFFD27DBE),
    memoryLevelColors: [
      Color(0xFFCBB8EE),
      Color(0xFFB59DE0),
      Color(0xFF9D83D3),
      Color(0xFF8566C3),
      Color(0xFF6A4BA6),
    ],
    topicBackgrounds: [
      Color(0xFFF0EAFB),
      Color(0xFFFDEBD6),
      Color(0xFFE3F0EB),
    ],
    topicForegrounds: [
      Color(0xFF7A62B8),
      Color(0xFFC98A4B),
      Color(0xFF4E8C77),
    ],
  );

  static const dark = AppPalette(
    primary: Color(0xFFC4B2FF),
    onPrimary: Color(0xFF2B1B5E),
    primaryStrong: Color(0xFFDCD0FF),
    primarySoft: Color(0xFF9F87E8),
    secondary: Color(0xFF3A2F5C),
    background: Color(0xFF14121B),
    backgroundTinted: Color(0xFF18151F),
    card: Color(0xFF1E1A28),
    raised: Color(0xFF342B4C),
    textPrimary: Color(0xFFEEEAF7),
    textSecondary: Color(0xFFB4ADC7),
    textMuted: Color(0xFF847D99),
    label: Color(0xFFA99BD3),
    cardBorder: Color(0xFF2D2839),
    divider: Color(0xFF27232F),
    lavenderSurface: Color(0xFF231D33),
    lavenderBorder: Color(0xFF372D52),
    mutedSurface: Color(0xFF1F1B29),
    progressTrack: Color(0xFF2E2940),
    danger: Color(0xFFF0A3B4),
    dangerSurface: Color(0xFF2C1A21),
    dangerBorder: Color(0xFF4A2732),
    favorite: Color(0xFFE79AD3),
    memoryLevelColors: [
      Color(0xFF4E3F78),
      Color(0xFF62509A),
      Color(0xFF7B64BC),
      Color(0xFF977FD8),
      Color(0xFFB7A2F2),
    ],
    topicBackgrounds: [
      Color(0xFF2A2340),
      Color(0xFF35291D),
      Color(0xFF1D2E28),
    ],
    topicForegrounds: [
      Color(0xFFB9A5F0),
      Color(0xFFE2AE78),
      Color(0xFF86C9B0),
    ],
  );

  final Color primary;
  final Color onPrimary;
  final Color primaryStrong;
  final Color primarySoft;
  final Color secondary;
  final Color background;
  final Color backgroundTinted;
  final Color card;
  final Color raised;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color label;
  final Color cardBorder;
  final Color divider;
  final Color lavenderSurface;
  final Color lavenderBorder;
  final Color mutedSurface;
  final Color progressTrack;
  final Color danger;
  final Color dangerSurface;
  final Color dangerBorder;
  final Color favorite;
  final List<Color> memoryLevelColors;
  final List<Color> topicBackgrounds;
  final List<Color> topicForegrounds;

  TextStyle get sectionLabel =>
      AppTextStyles.sectionLabel.copyWith(color: label);

  TextStyle get body => AppTextStyles.body.copyWith(color: textSecondary);

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }
}

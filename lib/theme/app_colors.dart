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
    required this.accentSurface,
    required this.accentBorder,
    required this.mutedSurface,
    required this.progressTrack,
    required this.danger,
    required this.dangerSurface,
    required this.dangerBorder,
    required this.favorite,
    required this.stamp,
    required this.chartColors,
    required this.memoryLevelColors,
    required this.topicBackgrounds,
    required this.topicForegrounds,
  });

  /// Giấy washi: nền kem, mực sumi, màu chính chàm (藍), đỏ son (朱) cho dấu.
  static const light = AppPalette(
    primary: Color(0xFF1F3A5F),
    onPrimary: Color(0xFFF7F3EA),
    primaryStrong: Color(0xFF152A46),
    primarySoft: Color(0xFF4D6F9A),
    secondary: Color(0xFFE2EAF3),
    background: Color(0xFFFCFAF6),
    backgroundTinted: Color(0xFFF7F3EC),
    card: Color(0xFFFFFFFF),
    raised: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF22201C),
    textSecondary: Color(0xFF5F5849),
    textMuted: Color(0xFF857D6E),
    label: Color(0xFF6B6458),
    cardBorder: Color(0xFFECE6DB),
    divider: Color(0xFFF0EBE2),
    accentSurface: Color(0xFFEEF3F8),
    accentBorder: Color(0xFFD3DEEB),
    mutedSurface: Color(0xFFF5F1EA),
    progressTrack: Color(0xFFEDE7DC),
    danger: Color(0xFFA8341F),
    dangerSurface: Color(0xFFF6E2DC),
    dangerBorder: Color(0xFFE6B9AD),
    favorite: Color(0xFFC23A24),
    stamp: Color(0xFFC8442F),
    chartColors: [
      Color(0xFFE8553E),
      Color(0xFFF2A93B),
      Color(0xFF4FA36B),
    ],
    memoryLevelColors: [
      Color(0xFFD9472F),
      Color(0xFFC98A2B),
      Color(0xFF6B8A2E),
      Color(0xFF4D6F9A),
      Color(0xFF1F3A5F),
    ],
    topicBackgrounds: [
      Color(0xFFEEF3F8),
      Color(0xFFFBECE8),
      Color(0xFFEFF3E6),
      Color(0xFFFAF1E2),
    ],
    topicForegrounds: [
      Color(0xFF1F3A5F),
      Color(0xFFA8341F),
      Color(0xFF4D6420),
      Color(0xFF8A5A12),
    ],
  );

  /// Mực sumi: nền than, chữ màu giấy, chàm sáng làm màu chính.
  static const dark = AppPalette(
    primary: Color(0xFF9DB7DA),
    onPrimary: Color(0xFF10213A),
    primaryStrong: Color(0xFFC3D4EA),
    primarySoft: Color(0xFF6F8FB8),
    secondary: Color(0xFF26354A),
    background: Color(0xFF17161A),
    backgroundTinted: Color(0xFF1B1A1E),
    card: Color(0xFF211F24),
    raised: Color(0xFF2C2A30),
    textPrimary: Color(0xFFEDE7DA),
    textSecondary: Color(0xFFB9B1A1),
    textMuted: Color(0xFF8E8676),
    label: Color(0xFFA99F8C),
    cardBorder: Color(0xFF34312D),
    divider: Color(0xFF2A2825),
    accentSurface: Color(0xFF1F2733),
    accentBorder: Color(0xFF34465E),
    mutedSurface: Color(0xFF232126),
    progressTrack: Color(0xFF34312D),
    danger: Color(0xFFF08F78),
    dangerSurface: Color(0xFF2E1D1A),
    dangerBorder: Color(0xFF5A2E25),
    favorite: Color(0xFFF08F78),
    stamp: Color(0xFFE8644B),
    chartColors: [
      Color(0xFFF07A63),
      Color(0xFFF5BE5E),
      Color(0xFF6FC18A),
    ],
    memoryLevelColors: [
      Color(0xFFE8644B),
      Color(0xFFD9A44A),
      Color(0xFF9CB861),
      Color(0xFF7FA0CB),
      Color(0xFFB7CBE6),
    ],
    topicBackgrounds: [
      Color(0xFF1F2733),
      Color(0xFF2E1D1A),
      Color(0xFF232A1C),
      Color(0xFF2E2618),
    ],
    topicForegrounds: [
      Color(0xFF9DB7DA),
      Color(0xFFF08F78),
      Color(0xFFA9C178),
      Color(0xFFE0B36A),
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
  final Color accentSurface;
  final Color accentBorder;
  final Color mutedSurface;
  final Color progressTrack;
  final Color danger;
  final Color dangerSurface;
  final Color dangerBorder;
  final Color favorite;

  /// Màu dấu triện hanko (chuỗi ngày, thành tích, đáp án đúng).
  final Color stamp;

  /// Màu 3 cột biểu đồ ghi nhớ: đỏ son (mới học), vàng hoa mai (đang nhớ),
  /// xanh lá tre (đã nhớ).
  final List<Color> chartColors;
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

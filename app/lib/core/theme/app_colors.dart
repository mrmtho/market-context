import 'package:flutter/material.dart';

/// Core color palette for Market Context.
///
/// The aesthetic is "deep space terminal": near-black indigo backgrounds,
/// translucent glass surfaces, and a cyan→violet neon accent system.
class AppColors {
  AppColors._();

  // Backgrounds (deepest to lightest).
  static const Color backgroundDeep = Color(0xFF05070F);
  static const Color background = Color(0xFF080B16);
  static const Color surface = Color(0xFF0E1322);
  static const Color surfaceElevated = Color(0xFF141A2C);
  static const Color surfaceHigh = Color(0xFF1B2237);

  // Hairline borders / dividers.
  static const Color border = Color(0x14FFFFFF); // ~8% white
  static const Color borderStrong = Color(0x24FFFFFF); // ~14% white

  // Text.
  static const Color textPrimary = Color(0xFFEAF0FA);
  static const Color textSecondary = Color(0xFF9AA7BE);
  static const Color textTertiary = Color(0xFF5E6B85);

  // Accent system.
  static const Color accentCyan = Color(0xFF2DE2E6);
  static const Color accentTeal = Color(0xFF31D0AA);
  static const Color accentViolet = Color(0xFF7C6CFF);
  static const Color accentBlue = Color(0xFF3F8CFF);
  static const Color accentMagenta = Color(0xFFB061FF);

  // Semantic.
  static const Color positive = Color(0xFF34E0A1);
  static const Color negative = Color(0xFFFF5470);
  static const Color neutral = Color(0xFF8C9BB5);
  static const Color warning = Color(0xFFFFC15E);
  static const Color info = Color(0xFF4DA3FF);

  // Glow / glass helpers.
  static Color glassFill = Colors.white.withValues(alpha: 0.04);
  static Color glassFillStrong = Colors.white.withValues(alpha: 0.07);
  static Color cyanGlow = accentCyan.withValues(alpha: 0.35);
  static Color violetGlow = accentViolet.withValues(alpha: 0.35);

  /// Maps a numeric delta to its semantic color.
  static Color forChange(num value) {
    if (value > 0) return positive;
    if (value < 0) return negative;
    return neutral;
  }
}

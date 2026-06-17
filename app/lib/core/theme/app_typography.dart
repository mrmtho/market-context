import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system.
///
/// - [display]/[heading] use Space Grotesk for a precise, technical feel.
/// - Body copy uses Inter for legibility.
/// - Numeric/tabular data uses JetBrains Mono so figures align in tables.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color base) {
    final heading = GoogleFonts.spaceGrotesk(color: base);
    return TextTheme(
      displayLarge: heading.copyWith(
          fontSize: 52, fontWeight: FontWeight.w600, letterSpacing: -1.5, height: 1.05),
      displayMedium: heading.copyWith(
          fontSize: 40, fontWeight: FontWeight.w600, letterSpacing: -1.0, height: 1.08),
      displaySmall: heading.copyWith(
          fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineMedium: heading.copyWith(
          fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.3),
      headlineSmall: heading.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleLarge: heading.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(
          color: base, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      titleSmall: GoogleFonts.inter(
          color: base, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.inter(color: base, fontSize: 15, height: 1.5),
      bodyMedium: GoogleFonts.inter(color: base, fontSize: 13.5, height: 1.5),
      bodySmall: GoogleFonts.inter(
          color: AppColors.textSecondary, fontSize: 12, height: 1.45),
      labelLarge: GoogleFonts.inter(
          color: base, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4),
      labelSmall: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8),
    );
  }

  /// Monospaced style for prices and tabular figures.
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Uppercase "eyebrow" label used above section titles.
  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: color ?? AppColors.textTertiary,
      );
}

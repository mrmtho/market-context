import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles the Material 3 [ThemeData] for Market Context.
///
/// The app is dark-first (that is the signature look); a light theme is
/// provided so the settings theme switcher is meaningful.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.accentCyan,
      onPrimary: Color(0xFF04121A),
      secondary: AppColors.accentViolet,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.negative,
      onError: Colors.white,
      outline: AppColors.borderStrong,
    );

    final text = AppTypography.textTheme(AppColors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: text,
      dividerColor: AppColors.border,
      splashFactory: InkSparkle.splashFactory,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadii.brSm,
          border: Border.all(color: AppColors.borderStrong),
        ),
        textStyle: text.bodySmall?.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        waitDuration: const Duration(milliseconds: 400),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
            AppColors.textTertiary.withValues(alpha: 0.4)),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: text.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      ),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: Color(0xFF0E8F9B),
      secondary: AppColors.accentViolet,
      surface: Colors.white,
      onSurface: Color(0xFF101725),
      error: AppColors.negative,
    );
    final text = AppTypography.textTheme(const Color(0xFF101725));
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF3F5FA),
      textTheme: text,
    );
  }
}

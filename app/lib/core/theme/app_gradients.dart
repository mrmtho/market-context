import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable gradients that give the app its luminous, futuristic feel.
class AppGradients {
  AppGradients._();

  /// Primary cyan → violet accent sweep.
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentCyan, AppColors.accentViolet],
  );

  /// Softer accent used for fills and chips.
  static LinearGradient accentSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accentCyan.withValues(alpha: 0.22),
      AppColors.accentViolet.withValues(alpha: 0.22),
    ],
  );

  /// Vertical glass surface sheen.
  static LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.06),
      Colors.white.withValues(alpha: 0.015),
    ],
  );

  /// Ambient page background — deep radial wash with a hint of color.
  static const RadialGradient ambient = RadialGradient(
    center: Alignment(-0.7, -0.9),
    radius: 1.6,
    colors: [
      Color(0xFF101A33),
      AppColors.background,
      AppColors.backgroundDeep,
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Chart area fill under a positive line.
  static LinearGradient chartFill(Color color) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.28),
          color.withValues(alpha: 0.0),
        ],
      );
}

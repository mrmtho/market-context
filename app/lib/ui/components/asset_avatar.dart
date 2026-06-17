import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/asset.dart';

/// A deterministic, colorful logo placeholder for an asset (Feature 2, task 11).
class AssetAvatar extends StatelessWidget {
  const AssetAvatar({super.key, required this.asset, this.size = 40});
  final Asset asset;
  final double size;

  static const _palettes = [
    [AppColors.accentCyan, AppColors.accentBlue],
    [AppColors.accentViolet, AppColors.accentMagenta],
    [AppColors.accentTeal, AppColors.accentCyan],
    [AppColors.accentBlue, AppColors.accentViolet],
    [AppColors.warning, AppColors.negative],
    [AppColors.positive, AppColors.accentTeal],
  ];

  @override
  Widget build(BuildContext context) {
    final pair = _palettes[asset.accentSeed % _palettes.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [pair[0].withValues(alpha: 0.9), pair[1].withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(size * 0.28)),
        boxShadow: [
          BoxShadow(color: pair[0].withValues(alpha: 0.35), blurRadius: 14, spreadRadius: -4),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        asset.avatarText,
        style: TextStyle(
          color: const Color(0xFF06101C),
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

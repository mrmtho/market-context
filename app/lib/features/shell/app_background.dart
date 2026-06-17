import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// The ambient backdrop for the whole app: a deep radial gradient with two
/// soft, blurred color "auroras" that give the futuristic, luminous feel.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.ambient),
      child: Stack(
        children: [
          Positioned(
            top: -160,
            left: -120,
            child: _Aurora(color: AppColors.accentViolet.withValues(alpha: 0.18), size: 420),
          ),
          Positioned(
            bottom: -200,
            right: -140,
            child: _Aurora(color: AppColors.accentCyan.withValues(alpha: 0.14), size: 520),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Aurora extends StatelessWidget {
  const _Aurora({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

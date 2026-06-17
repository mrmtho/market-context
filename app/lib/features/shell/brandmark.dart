import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_typography.dart';

/// The Market Context logo: a glowing gradient glyph + wordmark.
class Brandmark extends StatelessWidget {
  const Brandmark({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final glyph = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: AppColors.accentCyan.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: -2),
        ],
      ),
      child: const Icon(Icons.candlestick_chart_rounded, size: 19, color: Color(0xFF04121A)),
    );

    if (compact) return glyph;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        glyph,
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MARKET',
                style: AppTypography.eyebrow(color: AppColors.textTertiary)
                    .copyWith(letterSpacing: 3, height: 1)),
            ShaderMask(
              shaderCallback: (r) => AppGradients.accent.createShader(r),
              child: Text('CONTEXT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1,
                        height: 1.1,
                      )),
            ),
          ],
        ),
      ],
    );
  }
}

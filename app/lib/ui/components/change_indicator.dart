import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';

/// Displays a signed change with a directional arrow and semantic color.
/// Optionally renders as a filled pill.
class ChangeIndicator extends StatelessWidget {
  const ChangeIndicator({
    super.key,
    required this.percent,
    this.absolute,
    this.currency = 'USD',
    this.size = 13,
    this.pill = false,
    this.showArrow = true,
  });

  final double percent;
  final double? absolute;
  final String currency;
  final double size;
  final bool pill;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forChange(percent);
    final icon = percent > 0
        ? Icons.arrow_upward_rounded
        : percent < 0
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;

    final text = absolute != null
        ? '${Fmt.signedPrice(absolute!, currency: currency)}  (${Fmt.percent(percent)})'
        : Fmt.percent(percent);

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showArrow) ...[
          Icon(icon, size: size + 2, color: color),
          const SizedBox(width: 3),
        ],
        Text(text, style: AppTypography.mono(size: size, weight: FontWeight.w600, color: color)),
      ],
    );

    if (!pill) return row;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: row,
    );
  }
}

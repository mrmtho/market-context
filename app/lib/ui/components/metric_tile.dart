import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// A compact labelled value tile used throughout context layers.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.sublabel,
    this.valueColor,
    this.trailing,
    this.help,
    this.dense = false,
  });

  final String label;
  final String value;
  final String? sublabel;
  final Color? valueColor;
  final Widget? trailing;
  final String? help;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(dense ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppTypography.eyebrow(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (help != null)
                Tooltip(
                  message: help!,
                  child: const Icon(Icons.info_outline_rounded,
                      size: 13, color: AppColors.textTertiary),
                ),
            ],
          ),
          SizedBox(height: dense ? 4 : 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.mono(
                    size: dense ? 16 : 19,
                    weight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
            ],
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 3),
            Text(sublabel!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

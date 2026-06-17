import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'glass_container.dart';

/// Standard content card with an optional eyebrow label, title, leading icon,
/// trailing action and accent glow. Used by every context "layer".
class MCCard extends StatelessWidget {
  const MCCard({
    super.key,
    this.eyebrow,
    this.title,
    this.icon,
    this.accent,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    required this.child,
  });

  final String? eyebrow;
  final String? title;
  final IconData? icon;
  final Color? accent;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? AppColors.accentCyan;
    final hasHeader = title != null || icon != null || trailing != null;
    return GlassContainer(
      padding: padding,
      onTap: onTap,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: AppRadii.brSm,
                      border: Border.all(
                          color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
                  AppSpacing.hGapMd,
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null)
                        Text(eyebrow!.toUpperCase(),
                            style: AppTypography.eyebrow(color: accentColor)),
                      if (title != null)
                        Text(title!,
                            style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            AppSpacing.vGapLg,
          ],
          child,
        ],
      ),
    );
  }
}

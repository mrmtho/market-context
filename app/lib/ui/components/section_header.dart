import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// A titled section divider with an optional eyebrow and trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.accent = AppColors.accentCyan,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 26,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.6), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Text(eyebrow!.toUpperCase(),
                    style: AppTypography.eyebrow(color: accent)),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

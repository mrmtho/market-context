import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'mc_button.dart';

/// Reusable empty-state panel.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.travel_explore_rounded,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 28),
            ),
            AppSpacing.vGapLg,
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            if (message != null) ...[
              AppSpacing.vGapSm,
              SizedBox(
                width: 320,
                child: Text(message!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center),
              ),
            ],
            if (action != null) ...[AppSpacing.vGapLg, action!],
          ],
        ),
      ),
    );
  }
}

/// Reusable error panel with a retry action.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.compact = false,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.negative, size: compact ? 28 : 40),
            AppSpacing.vGapMd,
            Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            if (message != null) ...[
              AppSpacing.vGapSm,
              Text(message!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              AppSpacing.vGapLg,
              MCSecondaryButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                size: MCButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A subtle banner warning that displayed data may be stale or nearest-match.
class StaleDataBanner extends StatelessWidget {
  const StaleDataBanner({super.key, required this.message, this.icon});
  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppRadii.brSm,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.schedule_rounded,
              size: 15, color: AppColors.warning),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_market_data.dart';
import '../../data/providers/insights_controller.dart';
import '../../ui/components/asset_avatar.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/mc_badge.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/status_views.dart';
import '../shell/brandmark.dart';

/// Public/shareable insight page (Feature 14, route /insights/:id).
class SharedInsightScreen extends ConsumerWidget {
  const SharedInsightScreen({super.key, required this.insightId});
  final String insightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(insightsProvider.select(
        (list) => list.where((e) => e.id == insightId).firstOrNull));

    if (insight == null) {
      return PageScaffold(
        child: EmptyStateView(
          icon: Icons.link_off_rounded,
          title: 'Insight not found',
          message:
              'This insight may have been deleted, or the link was created on another device (insights are stored locally in this demo).',
          action: MCSecondaryButton(
            label: 'Back to saved',
            onPressed: () => context.go('/saved'),
          ),
        ),
      );
    }

    final asset = MockMarketData.instance.assetById(insight.assetId);

    return PageScaffold(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Brandmark(),
          AppSpacing.vGapLg,
          GlassContainer(
            glow: AppColors.accentMagenta,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (asset != null) ...[
                      AssetAvatar(asset: asset, size: 52),
                      AppSpacing.hGapLg,
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight.name,
                              style: Theme.of(context).textTheme.headlineSmall),
                          Row(
                            children: [
                              Text(insight.ticker,
                                  style: AppTypography.mono(
                                      size: 13,
                                      weight: FontWeight.w700,
                                      color: AppColors.accentCyan)),
                              AppSpacing.hGapSm,
                              MCBadge(label: insight.kind, color: AppColors.accentMagenta),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGapXl,
                Text(insight.title,
                    style: Theme.of(context).textTheme.headlineMedium),
                AppSpacing.vGapMd,
                Text(insight.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
                AppSpacing.vGapXl,
                Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.md,
                  children: [
                    if (insight.priceAtSave != null)
                      _meta(context, 'Price', Fmt.priceExact(insight.priceAtSave!)),
                    _meta(context, 'Context date', Fmt.date(insight.referenceDate)),
                    _meta(context, 'Saved', Fmt.date(insight.createdAt)),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          Row(
            children: [
              if (asset != null)
                MCPrimaryButton(
                  label: 'Open ${insight.ticker} dashboard',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => context.go('/asset/${insight.ticker}'),
                ),
              AppSpacing.hGapMd,
              MCSecondaryButton(
                label: 'Copy link',
                icon: Icons.link_rounded,
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: 'https://market-context.app/insights/${insight.id}'));
                  ref.read(analyticsProvider).log(
                      AnalyticsEvents.insightShared, {'id': insight.id});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share link copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppTypography.eyebrow()),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.mono(size: 15, weight: FontWeight.w600)),
      ],
    );
  }
}

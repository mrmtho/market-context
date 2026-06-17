import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_market_data.dart';
import '../../data/models/user_data.dart';
import '../../data/providers/insights_controller.dart';
import '../../ui/components/asset_avatar.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/mc_badge.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/section_header.dart';
import '../../ui/components/status_views.dart';
import '../search/search_overlay.dart';

class InsightsListScreen extends ConsumerWidget {
  const InsightsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    final cols = context.responsive(mobile: 1, tablet: 2, desktop: 2);

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: '${insights.length} saved',
            title: 'Saved insights',
            accent: AppColors.accentMagenta,
          ),
          AppSpacing.vGapLg,
          if (insights.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: EmptyStateView(
                icon: Icons.bookmark_outline_rounded,
                title: 'No saved insights yet',
                message:
                    'Save a context snapshot from any asset to revisit or share it later.',
                action: MCPrimaryButton(
                  label: 'Explore assets',
                  icon: Icons.search_rounded,
                  onPressed: () => showSearchOverlay(context),
                ),
              ),
            )
          else
            LayoutBuilder(builder: (context, c) {
              const gap = AppSpacing.lg;
              final w = cols == 1 ? c.maxWidth : (c.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final ins in insights)
                    SizedBox(width: w, child: _InsightCard(insight: ins)),
                ],
              );
            }),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }
}

class _InsightCard extends ConsumerWidget {
  const _InsightCard({required this.insight});
  final SavedInsight insight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = MockMarketData.instance.assetById(insight.assetId);
    return GlassContainer(
      onTap: () => context.go('/insights/${insight.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (asset != null) ...[
                AssetAvatar(asset: asset, size: 38),
                AppSpacing.hGapMd,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insight.ticker, style: Theme.of(context).textTheme.titleMedium),
                    Text(Fmt.date(insight.referenceDate),
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              MCBadge(label: insight.kind, color: AppColors.accentMagenta),
            ],
          ),
          AppSpacing.vGapMd,
          Text(insight.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(insight.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
          AppSpacing.vGapMd,
          Row(
            children: [
              Text('Saved ${Fmt.date(insight.createdAt)}',
                  style: Theme.of(context).textTheme.labelSmall),
              const Spacer(),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppColors.textTertiary,
                onPressed: () =>
                    ref.read(insightsProvider.notifier).remove(insight.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

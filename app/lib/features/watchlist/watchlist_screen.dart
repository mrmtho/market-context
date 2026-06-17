import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock/mock_market_data.dart';
import '../../data/models/user_data.dart';
import '../../data/providers/preferences_controller.dart';
import '../../data/providers/watchlist_controller.dart';
import '../../ui/components/asset_avatar.dart';
import '../../ui/components/change_indicator.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/mc_chip.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/section_header.dart';
import '../../ui/components/sparkline.dart';
import '../../ui/components/status_views.dart';
import '../search/search_overlay.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(watchlistProvider);
    final sort = ref.watch(watchlistSortProvider);
    final data = MockMarketData.instance;

    final sorted = [...items];
    switch (sort) {
      case WatchlistSort.ticker:
        sorted.sort((a, b) => a.ticker.compareTo(b.ticker));
        break;
      case WatchlistSort.change:
        sorted.sort((a, b) =>
            data.quote(b.assetId).changePercent.compareTo(
                data.quote(a.assetId).changePercent));
        break;
      case WatchlistSort.recent:
        sorted.sort((a, b) => (b.lastViewedAt ?? b.addedAt)
            .compareTo(a.lastViewedAt ?? a.addedAt));
        break;
    }

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: '${items.length} saved',
            title: 'Watchlist',
            accent: AppColors.warning,
            trailing: MCPrimaryButton(
              label: 'Add asset',
              icon: Icons.add_rounded,
              size: MCButtonSize.small,
              onPressed: () => showSearchOverlay(context),
            ),
          ),
          AppSpacing.vGapLg,
          if (items.isEmpty)
            const _Empty()
          else ...[
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _sortChip(ref, 'Recently viewed', WatchlistSort.recent, sort),
                _sortChip(ref, 'Ticker', WatchlistSort.ticker, sort),
                _sortChip(ref, 'Day change', WatchlistSort.change, sort),
              ],
            ),
            AppSpacing.vGapLg,
            for (final item in sorted)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _WatchRow(item: item),
              ),
          ],
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  Widget _sortChip(WidgetRef ref, String label, WatchlistSort value, WatchlistSort current) {
    return MCChip(
      label: label,
      accent: AppColors.warning,
      selected: value == current,
      onTap: () => ref.read(watchlistSortProvider.notifier).state = value,
    );
  }
}

class _WatchRow extends ConsumerWidget {
  const _WatchRow({required this.item});
  final WatchlistItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = MockMarketData.instance;
    final asset = data.assetById(item.assetId);
    if (asset == null) return const SizedBox.shrink();
    final q = data.quote(item.assetId);
    final currency = ref.watch(preferencesProvider.select((p) => p.currency));
    final isMobile = context.isMobile;
    final spark = data.fullSeries(item.assetId);
    final sparkVals = spark.sublist(spark.length - 30).map((p) => p.close).toList();

    return GlassContainer(
      onTap: () => context.go('/asset/${asset.ticker}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AssetAvatar(asset: asset, size: 44),
          AppSpacing.hGapMd,
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.ticker, style: Theme.of(context).textTheme.titleMedium),
                Text(asset.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (!isMobile) ...[
            Sparkline(
              values: sparkVals,
              color: AppColors.forChange(q.changePercent),
              width: 84,
              height: 34,
            ),
            AppSpacing.hGapLg,
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${q.price.toStringAsFixed(2)}',
                  style: AppTypography.mono(size: 15, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              ChangeIndicator(percent: q.changePercent, size: 12),
            ],
          ),
          AppSpacing.hGapSm,
          MCIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Remove',
            accent: AppColors.negative,
            onPressed: () =>
                ref.read(watchlistProvider.notifier).remove(item.assetId),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: EmptyStateView(
        icon: Icons.star_outline_rounded,
        title: 'Your watchlist is empty',
        message: 'Add assets to track their price and context at a glance.',
        action: MCPrimaryButton(
          label: 'Find assets',
          icon: Icons.search_rounded,
          onPressed: () => showSearchOverlay(context),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/asset.dart';
import '../../data/providers/preferences_controller.dart';
import '../../data/providers/providers.dart';
import '../../data/providers/watchlist_controller.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/loading_skeleton.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/status_views.dart';
import '../insights/insight_actions.dart';
import 'widgets/asset_header.dart';
import 'widgets/comparison_section.dart';
import 'widgets/context_panel.dart';
import 'widgets/narrative_card.dart';
import 'widgets/news_timeline.dart';
import 'widgets/price_timeline_card.dart';
import 'widgets/same_price_card.dart';

/// The main asset page combining price, chart and every context layer
/// (Features 3–11, composition §14.1).
class AssetDashboardScreen extends ConsumerStatefulWidget {
  const AssetDashboardScreen({super.key, required this.symbol});
  final String symbol;

  @override
  ConsumerState<AssetDashboardScreen> createState() =>
      _AssetDashboardScreenState();
}

class _AssetDashboardScreenState extends ConsumerState<AssetDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Honor the user's default chart range + reset any prior date selection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(preferencesProvider);
      ref.read(selectedRangeProvider(widget.symbol).notifier).state =
          prefs.defaultRange;
      ref.read(selectedDateProvider(widget.symbol).notifier).state = null;
      ref.read(analyticsProvider).log(
          AnalyticsEvents.assetOpened, {'ticker': widget.symbol});
    });
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(overviewProvider(widget.symbol));
    final currency = ref.watch(preferencesProvider.select((p) => p.currency));

    return overview.when(
      loading: () => const PageScaffold(child: _DashboardSkeleton()),
      error: (e, _) => PageScaffold(
        child: ErrorStateView(
          title: 'Could not load ${widget.symbol}',
          message: e.toString(),
          onRetry: () => ref.invalidate(overviewProvider(widget.symbol)),
        ),
      ),
      data: (ov) {
        // Mark as recently viewed if it's on the watchlist.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ref.read(watchlistProvider.notifier).markViewed(ov.asset.id);
          }
        });
        return PageScaffold(
          child: _DashboardBody(overview: ov, currency: currency),
        );
      },
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.overview, required this.currency});
  final AssetOverview overview;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Asset asset = overview.asset;
    final symbol = asset.ticker;
    final accent = AppColors.forChange(overview.changePercent);

    void shareCurrent() {
      final snap = ref.read(snapshotProvider(
          (id: symbol, date: overview.asOf))).valueOrNull;
      if (snap != null) {
        saveSnapshotInsight(context, ref, asset: asset, snapshot: snap);
      }
    }

    final header = AssetHeader(
      overview: overview,
      currency: currency,
      onShare: shareCurrent,
    );

    final chart = PriceTimelineCard(symbol: symbol, currency: currency, accent: accent);
    final contextPanel = ContextPanel(
      symbol: symbol,
      currency: currency,
      defaultDate: overview.asOf,
      onSaveSnapshot: (snap) =>
          saveSnapshotInsight(context, ref, asset: asset, snapshot: snap),
    );
    final narrative = NarrativeCard(symbol: symbol);
    final comparison = ComparisonSection(symbol: symbol);
    final samePrice = SamePriceCard(symbol: symbol, currency: currency);
    final news = NewsTimeline(symbol: symbol);
    final scenario = _ScenarioCta(symbol: symbol);

    final isDesktop = context.isDesktopOrWider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        AppSpacing.vGapLg,
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    chart,
                    AppSpacing.vGapLg,
                    comparison,
                    AppSpacing.vGapLg,
                    samePrice,
                    AppSpacing.vGapLg,
                    news,
                  ],
                ),
              ),
              AppSpacing.hGapLg,
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    contextPanel,
                    AppSpacing.vGapLg,
                    narrative,
                    AppSpacing.vGapLg,
                    scenario,
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              chart,
              AppSpacing.vGapLg,
              contextPanel,
              AppSpacing.vGapLg,
              narrative,
              AppSpacing.vGapLg,
              comparison,
              AppSpacing.vGapLg,
              samePrice,
              AppSpacing.vGapLg,
              news,
              AppSpacing.vGapLg,
              scenario,
            ],
          ),
        AppSpacing.vGapXl,
      ],
    );
  }
}

class _ScenarioCta extends StatelessWidget {
  const _ScenarioCta({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      glow: AppColors.accentViolet,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.accentSoft,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.accentViolet.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.accentViolet),
          ),
          AppSpacing.hGapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore assumptions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text('See how growth, margins and rates reshape the implied value.',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          AppSpacing.hGapMd,
          MCSecondaryButton(
            label: 'Open',
            icon: Icons.arrow_forward_rounded,
            size: MCButtonSize.small,
            onPressed: () => context.go('/asset/$symbol/scenario'),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonCard(height: 180, lines: 2),
        SizedBox(height: AppSpacing.lg),
        SkeletonCard(height: 360),
        SizedBox(height: AppSpacing.lg),
        SkeletonCard(height: 240),
      ],
    );
  }
}

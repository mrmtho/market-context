import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/asset.dart';
import '../../data/providers/providers.dart';
import '../../ui/components/asset_avatar.dart';
import '../../ui/components/change_indicator.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/loading_skeleton.dart';
import '../../ui/components/mc_badge.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/section_header.dart';
import '../../ui/components/sparkline.dart';
import '../../ui/components/status_views.dart';
import '../search/search_overlay.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingProvider);
    final cols = context.responsive(mobile: 1, tablet: 2, desktop: 3);

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Hero(),
          AppSpacing.vGapXl,
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            eyebrow: 'Live mock feed',
            title: 'Trending now',
            trailing: TextButton(
              onPressed: () => showSearchOverlay(context),
              child: const Text('Browse all'),
            ),
          ),
          AppSpacing.vGapLg,
          trending.when(
            loading: () => _grid(cols, [
              for (var i = 0; i < 6; i++) const SkeletonCard(height: 150),
            ]),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: () => ref.invalidate(trendingProvider),
            ),
            data: (items) => _grid(
              cols,
              [for (final r in items) _TrendingCard(result: r)],
            ),
          ),
          AppSpacing.vGapXl,
          const _ValueProps(),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  Widget _grid(int cols, List<Widget> children) {
    return LayoutBuilder(builder: (context, c) {
      const gap = AppSpacing.lg;
      final width = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children)
            SizedBox(width: cols == 1 ? c.maxWidth : width, child: child),
        ],
      );
    });
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return GlassContainer(
      padding: EdgeInsets.all(isMobile ? AppSpacing.xl : AppSpacing.xxl),
      blur: 20,
      glow: AppColors.accentViolet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppGradients.accentSoft,
              borderRadius: AppRadii.brPill,
              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.accentCyan),
                AppSpacing.hGapSm,
                Text('THE 3D MARKET PRICE',
                    style: AppTypography.eyebrow(color: AppColors.accentCyan)),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [AppColors.textPrimary, AppColors.accentCyan],
            ).createShader(r),
            child: Text(
              'Every price has context.',
              style: (isMobile
                      ? Theme.of(context).textTheme.displaySmall
                      : Theme.of(context).textTheme.displayMedium)
                  ?.copyWith(color: Colors.white),
            ),
          ),
          AppSpacing.vGapMd,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Google Finance, reimagined. See the economic conditions, '
              'company fundamentals, and market narrative behind any price — '
              'then compare today with how the world looked before.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          AppSpacing.vGapXl,
          _HeroSearchBar(onTap: () => showSearchOverlay(context)),
        ],
      ),
    );
  }
}

class _HeroSearchBar extends StatelessWidget {
  const _HeroSearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      fillOpacity: 0.08,
      borderColor: AppColors.borderStrong,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.accentCyan),
          AppSpacing.hGapMd,
          Expanded(
            child: Text('Search NVDA, Bitcoin, S&P 500…',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textTertiary,
                    )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: AppRadii.brPill,
            ),
            child: const Text('Search',
                style: TextStyle(
                    color: Color(0xFF04121A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.result});
  final AssetSearchResult result;

  @override
  Widget build(BuildContext context) {
    final a = result.asset;
    return GlassContainer(
      onTap: () => context.go('/asset/${a.ticker}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AssetAvatar(asset: a, size: 42),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.ticker, style: Theme.of(context).textTheme.titleLarge),
                    Text(a.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGapLg,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${result.lastPrice.toStringAsFixed(2)}',
                        style: AppTypography.mono(size: 22, weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    ChangeIndicator(percent: result.changePercent, size: 12),
                  ],
                ),
              ),
              Sparkline(
                values: List.generate(
                    16,
                    (i) => result.lastPrice *
                        (1 + (result.changePercent / 100) * (i / 15 - 0.5))),
                color: AppColors.forChange(result.changePercent),
                width: 80,
                height: 38,
              ),
            ],
          ),
          AppSpacing.vGapMd,
          MCBadge(label: a.assetType.label, color: AppColors.accentViolet),
        ],
      ),
    );
  }
}

class _ValueProps extends StatelessWidget {
  const _ValueProps();

  static const _items = [
    (Icons.travel_explore_rounded, 'Time machine',
        'Click any point in history and see the macro, valuation and news context for that exact date.'),
    (Icons.compare_arrows_rounded, 'Then vs now',
        'Compare today with 3, 6 or 12 months ago and instantly spot what really changed.'),
    (Icons.auto_graph_rounded, 'Same price, new story',
        'Find the last time an asset traded here — and why the same price can mean something completely different.'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isRow = c.maxWidth > 820;
      final cards = [
        for (final it in _items)
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppGradients.accentSoft,
                    borderRadius: AppRadii.brSm,
                    border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                  ),
                  child: Icon(it.$1, color: AppColors.accentCyan, size: 19),
                ),
                AppSpacing.vGapMd,
                Text(it.$2, style: Theme.of(context).textTheme.titleMedium),
                AppSpacing.vGapSm,
                Text(it.$3,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        )),
              ],
            ),
          ),
      ];
      if (!isRow) {
        return Column(
          children: [
            for (final card in cards)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: card,
              ),
          ],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) AppSpacing.hGapLg,
            ],
          ],
        ),
      );
    });
  }
}

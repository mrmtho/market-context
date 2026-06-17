import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/comparison.dart';
import '../../../data/providers/providers.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/components/loading_skeleton.dart';
import '../../../ui/components/section_header.dart';
import '../../../ui/components/status_views.dart';
import 'comparison_table.dart';

/// The flagship "3D price" feature: last time the asset traded here, and how
/// different the world was (Feature 11).
class SamePriceCard extends ConsumerWidget {
  const SamePriceCard({super.key, required this.symbol, required this.currency});
  final String symbol;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(samePriceProvider(symbol));

    return GlassContainer(
      glow: AppColors.accentCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: 'The 3D price',
            title: 'Same price, different world',
            trailing: IconButton(
              tooltip: 'Matches within a 2% price tolerance',
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              onPressed: () {},
            ),
          ),
          AppSpacing.vGapLg,
          match.when(
            loading: () => const SkeletonCard(height: 220, lines: 4),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: () => ref.invalidate(samePriceProvider(symbol)),
            ),
            data: (m) {
              if (m == null) {
                return const EmptyStateView(
                  icon: Icons.search_off_rounded,
                  title: 'No prior match found',
                  message:
                      'This asset has not traded near its current price within the available history.',
                );
              }
              ref.read(analyticsProvider).log(
                  AnalyticsEvents.samePriceOpened, {'ticker': symbol});
              return _Body(match: m, currency: currency);
            },
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.match, required this.currency});
  final SamePriceMatch match;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final months =
        match.comparison.nowDate.difference(match.matchDate).inDays ~/ 30;
    final isMobile = context.isMobile;

    final endpoints = [
      _PricePost(
        eyebrow: Fmt.monthYear(match.matchDate),
        price: Fmt.priceExact(match.matchPrice, currency: currency),
        caption: '$months months ago',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppGradients.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF04121A)),
        ),
      ),
      _PricePost(
        eyebrow: 'Today',
        price: Fmt.priceExact(match.currentPrice, currency: currency),
        caption: 'Same price level',
        highlight: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(children: [
            endpoints[0],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.arrow_downward_rounded, color: AppColors.accentCyan),
            ),
            endpoints[2],
          ])
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: endpoints[0]),
              endpoints[1],
              Expanded(child: endpoints[2]),
            ],
          ),
        AppSpacing.vGapLg,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.accentCyan.withValues(alpha: 0.12),
              AppColors.accentViolet.withValues(alpha: 0.08),
            ]),
            borderRadius: AppRadii.brMd,
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accentCyan, size: 18),
              AppSpacing.hGapMd,
              Expanded(
                child: Text(match.headline,
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ),
        AppSpacing.vGapLg,
        Text('THEN VS NOW', style: AppTypography.eyebrow()),
        ComparisonTable(
          comparison: match.comparison,
          thenLabel: Fmt.monthYear(match.matchDate),
          nowLabel: 'Today',
        ),
      ],
    );
  }
}

class _PricePost extends StatelessWidget {
  const _PricePost({
    required this.eyebrow,
    required this.price,
    required this.caption,
    this.highlight = false,
  });
  final String eyebrow;
  final String price;
  final String caption;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: highlight ? AppColors.accentCyan.withValues(alpha: 0.1) : AppColors.glassFill,
        borderRadius: AppRadii.brMd,
        border: Border.all(
          color: highlight ? AppColors.accentCyan.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: AppTypography.eyebrow()),
          const SizedBox(height: 6),
          Text(price, style: AppTypography.mono(size: 22, weight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

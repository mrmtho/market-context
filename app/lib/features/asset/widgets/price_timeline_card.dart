import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/mock/mock_market_data.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/providers.dart';
import '../../../ui/components/change_indicator.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/components/loading_skeleton.dart';
import '../../../ui/components/mc_chip.dart';
import '../../../ui/components/section_header.dart';
import '../../../ui/components/status_views.dart';
import 'price_chart.dart';

/// Chart container with time-range selector + interaction wiring (Feature 4).
class PriceTimelineCard extends ConsumerWidget {
  const PriceTimelineCard({
    super.key,
    required this.symbol,
    required this.currency,
    required this.accent,
  });

  final String symbol;
  final String currency;
  final Color accent;

  static const _ranges = TimeRange.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(selectedRangeProvider(symbol));
    final overlay = ref.watch(chartOverlayProvider(symbol));
    final history = ref.watch(priceHistoryProvider((id: symbol, range: range)));
    final overlayPoints = history.maybeWhen(
      data: (series) => MockMarketData.instance.overlayValues(symbol, series.points, overlay),
      orElse: () => const <double>[],
    );
    final events = ref.watch(eventsProvider(symbol)).valueOrNull ?? const [];
    final selectedDate = ref.watch(selectedDateProvider(symbol));
    final isMobile = context.isMobile;
    final chartHeight = isMobile ? 240.0 : 340.0;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  eyebrow: 'Interactive timeline',
                  title: 'Price history',
                ),
              ),
              history.maybeWhen(
                data: (s) => ChangeIndicator(
                  percent: s.changePercent,
                  size: 13,
                  pill: true,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          AppSpacing.vGapLg,
          SizedBox(
            height: chartHeight,
            child: history.when(
              loading: () => const _ChartSkeleton(),
              error: (e, _) => ErrorStateView(
                message: e.toString(),
                onRetry: () => ref.invalidate(
                    priceHistoryProvider((id: symbol, range: range))),
              ),
              data: (series) {
                if (series.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.show_chart_rounded,
                    title: 'No data for this range',
                  );
                }
                return PriceChart(
                  series: series,
                  currency: currency,
                  accent: accent,
                  events: events,
                  selectedDate: selectedDate,
                  overlayType: overlay,
                  overlayPoints: overlayPoints,
                  onSelectDate: (date) {
                    ref.read(selectedDateProvider(symbol).notifier).state = date;
                    ref.read(analyticsProvider).log(
                      AnalyticsEvents.chartDateSelected,
                      {'ticker': symbol, 'date': Fmt.date(date)},
                    );
                  },
                );
              },
            ),
          ),
          AppSpacing.vGapLg,
          AppSpacing.vGapLg,
          Text('BACKGROUND OVERLAY', style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final o in ChartOverlayType.values)
                MCChip(
                  label: o.label,
                  icon: o.icon,
                  selected: o == overlay,
                  onTap: () {
                    ref.read(chartOverlayProvider(symbol).notifier).state = o;
                    ref.read(analyticsProvider).log(
                      'chart_overlay_changed',
                      {'ticker': symbol, 'overlay': o.label},
                    );
                  },
                ),
            ],
          ),
          AppSpacing.vGapLg,
          Text('TIME RANGE', style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final r in _ranges)
                MCChip(
                  label: r.label,
                  selected: r == range,
                  onTap: () {
                    ref.read(selectedRangeProvider(symbol).notifier).state = r;
                    ref.read(analyticsProvider).log(
                      AnalyticsEvents.timeRangeChanged,
                      {'ticker': symbol, 'range': r.label},
                    );
                  },
                ),
            ],
          ),
          AppSpacing.vGapMd,
          Row(
            children: [
              _legendDot(AppColors.warning),
              AppSpacing.hGapSm,
              Text('Event marker', style: Theme.of(context).textTheme.labelSmall),
              AppSpacing.hGapLg,
              _legendDot(AppColors.accentViolet),
              AppSpacing.hGapSm,
              Text('Selected date · tap the chart to time-travel',
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 90, height: 14),
          Spacer(),
          SkeletonBox(width: double.infinity, height: 2),
          SizedBox(height: 24),
          SkeletonBox(width: double.infinity, height: 2),
          SizedBox(height: 24),
          SkeletonBox(width: double.infinity, height: 2),
          Spacer(),
        ],
      ),
    );
  }
}

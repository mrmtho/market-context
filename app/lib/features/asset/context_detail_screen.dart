import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_market_data.dart';
import '../../data/models/context_models.dart';
import '../../data/providers/preferences_controller.dart';
import '../../data/providers/providers.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/loading_skeleton.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/status_views.dart';
import 'widgets/comparison_table.dart';
import 'widgets/context_layers.dart';

/// Full-page deep context for a specific historical date (route §8.1).
class ContextDetailScreen extends ConsumerWidget {
  const ContextDetailScreen({super.key, required this.symbol, required this.dateIso});
  final String symbol;
  final String dateIso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.tryParse(dateIso);
    if (date == null) {
      return PageScaffold(
        child: ErrorStateView(title: 'Invalid date', message: dateIso),
      );
    }
    final currency = ref.watch(preferencesProvider.select((p) => p.currency));
    final snapshot = ref.watch(snapshotProvider((id: symbol, date: date)));

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MCSecondaryButton(
                label: symbol,
                icon: Icons.arrow_back_rounded,
                size: MCButtonSize.small,
                onPressed: () => context.go('/asset/$symbol'),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Text('Context · ${Fmt.date(date)}',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          AppSpacing.vGapLg,
          snapshot.when(
            loading: () => const SkeletonCard(height: 320),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: () =>
                  ref.invalidate(snapshotProvider((id: symbol, date: date))),
            ),
            data: (snap) => _Body(symbol: symbol, snapshot: snap, currency: currency),
          ),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.symbol, required this.snapshot, required this.currency});
  final String symbol;
  final ContextSnapshot snapshot;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final data = MockMarketData.instance;
    final comparison = data.compare(
        symbol, snapshot.nearestActualDate, data.now, 'vs Today');
    final cols = context.responsive(mobile: 1, tablet: 2, desktop: 2);

    final layers = [
      MacroLayerCard(metrics: snapshot.macro),
      ValuationLayerCard(metrics: snapshot.valuation),
      FundamentalsLayerCard(metrics: snapshot.fundamentals),
      SentimentLayerCard(signals: snapshot.sentiment),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (snapshot.isNearest)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StaleDataBanner(
              message:
                  'Nearest trading day: ${Fmt.date(snapshot.nearestActualDate)}.',
            ),
          ),
        GlassContainer(
          glow: AppColors.accentCyan,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PRICE ON ${Fmt.date(snapshot.nearestActualDate).toUpperCase()}',
                  style: AppTypography.eyebrow(color: AppColors.accentCyan)),
              const SizedBox(height: 6),
              Text(Fmt.priceExact(snapshot.price, currency: currency),
                  style: AppTypography.mono(size: 36, weight: FontWeight.w700)),
              AppSpacing.vGapSm,
              Text(snapshot.headline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      )),
            ],
          ),
        ),
        AppSpacing.vGapLg,
        LayoutBuilder(builder: (context, c) {
          const gap = AppSpacing.lg;
          final w = cols == 1 ? c.maxWidth : (c.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [for (final l in layers) SizedBox(width: w, child: l)],
          );
        }),
        AppSpacing.vGapLg,
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('THEN VS TODAY', style: AppTypography.eyebrow()),
              AppSpacing.vGapSm,
              Text(comparison.headline,
                  style: Theme.of(context).textTheme.bodyLarge),
              AppSpacing.vGapMd,
              ComparisonTable(
                comparison: comparison,
                thenLabel: Fmt.monthYear(snapshot.nearestActualDate),
                nowLabel: 'Today',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

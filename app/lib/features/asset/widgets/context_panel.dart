import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/context_models.dart';
import '../../../data/providers/providers.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/components/loading_skeleton.dart';
import '../../../ui/components/mc_button.dart';
import '../../../ui/components/status_views.dart';
import 'context_layers.dart';

/// The date-driven context panel (Feature 5). Shows everything about the asset
/// on the selected date — price, macro, valuation, fundamentals, sentiment.
class ContextPanel extends ConsumerWidget {
  const ContextPanel({
    super.key,
    required this.symbol,
    required this.currency,
    required this.defaultDate,
    this.onSaveSnapshot,
  });

  final String symbol;
  final String currency;
  final DateTime defaultDate;
  final void Function(ContextSnapshot snapshot)? onSaveSnapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider(symbol));
    final date = selectedDate ?? defaultDate;
    final snapshot = ref.watch(snapshotProvider((id: symbol, date: date)));
    final isLatest = selectedDate == null;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.travel_explore_rounded,
                  color: AppColors.accentCyan, size: 18),
              AppSpacing.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONTEXT SNAPSHOT', style: AppTypography.eyebrow()),
                    Text(isLatest ? 'Today · ${Fmt.date(date)}' : Fmt.date(date),
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              if (!isLatest)
                MCSecondaryButton(
                  label: 'Latest',
                  icon: Icons.restore_rounded,
                  size: MCButtonSize.small,
                  onPressed: () => ref
                      .read(selectedDateProvider(symbol).notifier)
                      .state = null,
                ),
            ],
          ),
          AppSpacing.vGapLg,
          snapshot.when(
            loading: () => const Column(
              children: [
                SkeletonCard(height: 90, lines: 2),
                SizedBox(height: AppSpacing.md),
                SkeletonCard(height: 160),
              ],
            ),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: () => ref.invalidate(
                  snapshotProvider((id: symbol, date: date))),
            ),
            data: (snap) => _SnapshotBody(
              snapshot: snap,
              symbol: symbol,
              currency: currency,
              onSave: onSaveSnapshot,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotBody extends StatelessWidget {
  const _SnapshotBody({
    required this.snapshot,
    required this.symbol,
    required this.currency,
    this.onSave,
  });

  final ContextSnapshot snapshot;
  final String symbol;
  final String currency;
  final void Function(ContextSnapshot snapshot)? onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (snapshot.isNearest)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: StaleDataBanner(
              message:
                  'Exact data unavailable — showing nearest trading day, ${Fmt.date(snapshot.nearestActualDate)}.',
            ),
          ),
        // Price-at-date hero.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentCyan.withValues(alpha: 0.12),
                AppColors.accentViolet.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: AppRadii.brMd,
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PRICE ON THIS DATE', style: AppTypography.eyebrow()),
              const SizedBox(height: 6),
              Text(Fmt.priceExact(snapshot.price, currency: currency),
                  style: AppTypography.mono(size: 28, weight: FontWeight.w700)),
              AppSpacing.vGapSm,
              Text(snapshot.headline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      )),
            ],
          ),
        ),
        AppSpacing.vGapMd,
        MacroLayerCard(metrics: snapshot.macro),
        AppSpacing.vGapMd,
        ValuationLayerCard(metrics: snapshot.valuation),
        AppSpacing.vGapMd,
        FundamentalsLayerCard(metrics: snapshot.fundamentals),
        AppSpacing.vGapMd,
        SentimentLayerCard(signals: snapshot.sentiment),
        AppSpacing.vGapLg,
        Row(
          children: [
            Expanded(
              child: MCSecondaryButton(
                label: 'Full context view',
                icon: Icons.open_in_full_rounded,
                expand: true,
                size: MCButtonSize.small,
                onPressed: () => context.go(
                  '/asset/$symbol/context/${snapshot.nearestActualDate.toIso8601String().substring(0, 10)}',
                ),
              ),
            ),
            if (onSave != null) ...[
              AppSpacing.hGapSm,
              MCIconButton(
                icon: Icons.bookmark_add_outlined,
                tooltip: 'Save this snapshot',
                onPressed: () => onSave!(snapshot),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

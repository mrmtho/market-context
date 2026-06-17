import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/mock/mock_market_data.dart';
import '../../../data/models/comparison.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/providers.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/components/loading_skeleton.dart';
import '../../../ui/components/mc_chip.dart';
import '../../../ui/components/section_header.dart';
import '../../../ui/components/status_views.dart';
import 'comparison_table.dart';

final _periodProvider = StateProvider.family<ComparisonPeriod, String>(
    (ref, id) => ComparisonPeriod.m6);
final _customDateProvider =
    StateProvider.family<DateTime?, String>((ref, id) => null);

/// Time comparison engine UI (Feature 6).
class ComparisonSection extends ConsumerWidget {
  const ComparisonSection({super.key, required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(_periodProvider(symbol));
    final custom = ref.watch(_customDateProvider(symbol));
    final comparison = ref.watch(comparisonProvider(
        (id: symbol, period: period, customDate: custom)));

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Then vs now',
            title: 'Time comparison',
            accent: AppColors.accentViolet,
          ),
          AppSpacing.vGapLg,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in ComparisonPeriod.values)
                MCChip(
                  label: p == ComparisonPeriod.custom && custom != null
                      ? Fmt.monthYear(custom)
                      : p.label,
                  icon: p == ComparisonPeriod.custom ? Icons.event_rounded : null,
                  accent: AppColors.accentViolet,
                  selected: p == period,
                  onTap: () async {
                    if (p == ComparisonPeriod.custom) {
                      final picked = await _pickDate(context, custom);
                      if (picked != null) {
                        ref.read(_customDateProvider(symbol).notifier).state = picked;
                      }
                    }
                    ref.read(_periodProvider(symbol).notifier).state = p;
                    ref.read(analyticsProvider).log(
                      AnalyticsEvents.comparisonPeriodSelected,
                      {'ticker': symbol, 'period': p.label},
                    );
                  },
                ),
            ],
          ),
          AppSpacing.vGapLg,
          comparison.when(
            loading: () => const SkeletonCard(height: 220, lines: 5),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: () => ref.invalidate(comparisonProvider(
                  (id: symbol, period: period, customDate: custom))),
            ),
            data: (c) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopDifferences(comparison: c),
                AppSpacing.vGapLg,
                ComparisonTable(comparison: c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? current) {
    final now = MockMarketData.instance.now;
    return showDatePicker(
      context: context,
      initialDate: current ?? now.subtract(const Duration(days: 365)),
      firstDate: now.subtract(const Duration(days: 365 * 11)),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accentCyan,
            surface: AppColors.surfaceElevated,
          ),
        ),
        child: child!,
      ),
    );
  }
}

class _TopDifferences extends StatelessWidget {
  const _TopDifferences({required this.comparison});
  final ContextComparison comparison;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accentViolet.withValues(alpha: 0.12),
          AppColors.accentCyan.withValues(alpha: 0.08),
        ]),
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 16, color: AppColors.accentViolet),
              AppSpacing.hGapSm,
              Text('BIGGEST SHIFTS', style: AppTypography.eyebrow(color: AppColors.accentViolet)),
            ],
          ),
          AppSpacing.vGapSm,
          Text(comparison.headline,
              style: Theme.of(context).textTheme.bodyLarge),
          AppSpacing.vGapMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final r in comparison.topDifferences)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: AppRadii.brSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${r.label}: ',
                          style: Theme.of(context).textTheme.labelMedium),
                      Text('${r.thenDisplay} → ${r.nowDisplay}',
                          style: AppTypography.mono(size: 12, weight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

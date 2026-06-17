import 'package:flutter/material.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/comparison.dart';
import '../../../data/models/enums.dart';

Color _semanticColor(ChangeSemantic s) => switch (s) {
      ChangeSemantic.positive => AppColors.positive,
      ChangeSemantic.negative => AppColors.negative,
      ChangeSemantic.neutral => AppColors.neutral,
    };

/// Renders a [ContextComparison] as a grouped then-vs-now layout that adapts:
/// a 4-column table on wide screens, stacked cards on mobile (Feature 6, 9).
class ComparisonTable extends StatelessWidget {
  const ComparisonTable({
    super.key,
    required this.comparison,
    this.thenLabel,
    this.nowLabel,
  });

  final ContextComparison comparison;
  final String? thenLabel;
  final String? nowLabel;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final groups = comparison.groups;
    final tLabel = thenLabel ?? Fmt.monthYear(comparison.thenDate);
    final nLabel = nowLabel ?? 'Now';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
            child: Text(group.toUpperCase(), style: AppTypography.eyebrow()),
          ),
          if (!isMobile) _TableHeader(thenLabel: tLabel, nowLabel: nLabel),
          for (final row in comparison.rows.where((r) => r.group == group))
            isMobile
                ? _RowCard(row: row, thenLabel: tLabel, nowLabel: nLabel)
                : _TableRow(row: row),
        ],
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.thenLabel, required this.nowLabel});
  final String thenLabel;
  final String nowLabel;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.eyebrow();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('METRIC', style: style)),
          Expanded(flex: 3, child: Text(thenLabel.toUpperCase(), textAlign: TextAlign.right, style: style)),
          Expanded(flex: 3, child: Text(nowLabel.toUpperCase(), textAlign: TextAlign.right, style: style)),
          Expanded(flex: 3, child: Text('CHANGE', textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.row});
  final ComparisonRow row;

  @override
  Widget build(BuildContext context) {
    final color = _semanticColor(row.semantic);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(row.label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(row.thenDisplay,
                textAlign: TextAlign.right,
                style: AppTypography.mono(size: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: Text(row.nowDisplay,
                textAlign: TextAlign.right,
                style: AppTypography.mono(size: 13, weight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.deltaPercent.abs() < 0.05 ? '—' : Fmt.percent(row.deltaPercent),
              textAlign: TextAlign.right,
              style: AppTypography.mono(size: 12, weight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.row, required this.thenLabel, required this.nowLabel});
  final ComparisonRow row;
  final String thenLabel;
  final String nowLabel;

  @override
  Widget build(BuildContext context) {
    final color = _semanticColor(row.semantic);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(row.label,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Text(
                row.deltaPercent.abs() < 0.05 ? '—' : Fmt.percent(row.deltaPercent),
                style: AppTypography.mono(size: 12, weight: FontWeight.w700, color: color),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Row(
            children: [
              Expanded(child: _cell(context, thenLabel, row.thenDisplay, AppColors.textSecondary)),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(child: _cell(context, nowLabel, row.nowDisplay, AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.eyebrow()),
        const SizedBox(height: 3),
        Text(value, style: AppTypography.mono(size: 14, weight: FontWeight.w600, color: color)),
      ],
    );
  }
}

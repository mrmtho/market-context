import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/context_models.dart';
import '../../../ui/components/mc_card.dart';
import '../../../ui/components/metric_tile.dart';
import '../../../ui/components/sparkline.dart';

/// Macro layer (Feature 7): metric rows with sparklines and "why it matters".
class MacroLayerCard extends StatelessWidget {
  const MacroLayerCard({super.key, required this.metrics, this.region = 'United States'});
  final List<MacroMetric> metrics;
  final String region;

  @override
  Widget build(BuildContext context) {
    return MCCard(
      eyebrow: 'Macro context · $region',
      title: 'The world around the price',
      icon: Icons.public_rounded,
      accent: AppColors.accentBlue,
      child: Column(
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            _MacroRow(metric: metrics[i]),
            if (i != metrics.length - 1)
              const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.metric});
  final MacroMetric metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(metric.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: metric.why,
                    child: const Icon(Icons.info_outline_rounded,
                        size: 13, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(metric.category.label,
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
        AppSpacing.hGapMd,
        Sparkline(values: metric.trend, width: 56, height: 22, fill: false),
        AppSpacing.hGapMd,
        SizedBox(
          width: 70,
          child: Text(
            metric.formattedValue,
            textAlign: TextAlign.right,
            style: AppTypography.mono(size: 14, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Valuation layer (Feature 8).
class ValuationLayerCard extends StatelessWidget {
  const ValuationLayerCard({super.key, required this.metrics});
  final List<ValuationMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const MCCard(
        eyebrow: 'Valuation',
        title: 'Valuation',
        icon: Icons.straighten_rounded,
        accent: AppColors.accentTeal,
        child: _NotApplicable(label: 'Valuation multiples apply to equities.'),
      );
    }
    return MCCard(
      eyebrow: 'Valuation',
      title: 'What you pay for the business',
      icon: Icons.straighten_rounded,
      accent: AppColors.accentTeal,
      child: _MetricGrid(
        children: [
          for (final m in metrics)
            MetricTile(
              label: m.name,
              value: m.display,
              help: m.definition,
              dense: true,
            ),
        ],
      ),
    );
  }
}

/// Fundamentals layer (Feature 8).
class FundamentalsLayerCard extends StatelessWidget {
  const FundamentalsLayerCard({super.key, required this.metrics});
  final List<FundamentalMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const MCCard(
        eyebrow: 'Fundamentals',
        title: 'Fundamentals',
        icon: Icons.account_tree_rounded,
        accent: AppColors.accentViolet,
        child: _NotApplicable(label: 'Business fundamentals apply to equities.'),
      );
    }
    return MCCard(
      eyebrow: 'Fundamentals · ${metrics.first.fiscalPeriod}',
      title: 'How the business is doing',
      icon: Icons.account_tree_rounded,
      accent: AppColors.accentViolet,
      child: _MetricGrid(
        children: [
          for (final m in metrics)
            MetricTile(
              label: m.name,
              value: m.display,
              sublabel: m.estimated ? 'Estimated' : '${m.basis} · Reported',
              help: m.definition,
              dense: true,
            ),
        ],
      ),
    );
  }
}

/// Sentiment layer.
class SentimentLayerCard extends StatelessWidget {
  const SentimentLayerCard({super.key, required this.signals});
  final List<SentimentSignal> signals;

  @override
  Widget build(BuildContext context) {
    return MCCard(
      eyebrow: 'Sentiment',
      title: 'How the market feels',
      icon: Icons.sensors_rounded,
      accent: AppColors.accentMagenta,
      child: Column(
        children: [
          for (final s in signals) ...[
            _SentimentRow(signal: s),
            if (s != signals.last) AppSpacing.vGapMd,
          ],
        ],
      ),
    );
  }
}

class _SentimentRow extends StatelessWidget {
  const _SentimentRow({required this.signal});
  final SentimentSignal signal;

  @override
  Widget build(BuildContext context) {
    final color = signal.score > 0.1
        ? AppColors.positive
        : signal.score < -0.1
            ? AppColors.negative
            : AppColors.neutral;
    final t = (signal.score + 1) / 2; // 0..1
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(signal.label,
                    style: Theme.of(context).textTheme.bodyMedium)),
            Text(signal.descriptor,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, c) {
          return Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: AppRadii.brPill,
                ),
              ),
              Container(
                height: 6,
                width: c.maxWidth * t.clamp(0.04, 1.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadii.brPill,
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 360 ? 2 : 1;
      const gap = AppSpacing.sm;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: w, child: child),
        ],
      );
    });
  }
}

class _NotApplicable extends StatelessWidget {
  const _NotApplicable({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textTertiary),
        AppSpacing.hGapSm,
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

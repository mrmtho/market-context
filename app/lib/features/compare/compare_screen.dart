import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_market_data.dart';
import '../../data/models/asset.dart';
import '../../data/models/enums.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/mc_chip.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/section_header.dart';

const _compareColors = [
  AppColors.accentCyan,
  AppColors.accentViolet,
  AppColors.warning,
  AppColors.accentTeal,
];

final _selectedAssetsProvider =
    StateProvider<List<String>>((ref) => ['NVDA', 'AAPL', 'BTC']);
final _compareRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.y1);

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedAssetsProvider);
    final range = ref.watch(_compareRangeProvider);
    final data = MockMarketData.instance;
    final allAssets = data.assets;

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Workspace',
            title: 'Compare assets',
            accent: AppColors.accentViolet,
          ),
          AppSpacing.vGapLg,
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SELECT UP TO 4 ASSETS', style: AppTypography.eyebrow()),
                AppSpacing.vGapMd,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final a in allAssets)
                      MCChip(
                        label: a.ticker,
                        selected: selected.contains(a.id),
                        onTap: () {
                          final next = [...selected];
                          if (next.contains(a.id)) {
                            if (next.length > 1) next.remove(a.id);
                          } else if (next.length < 4) {
                            next.add(a.id);
                          }
                          ref.read(_selectedAssetsProvider.notifier).state = next;
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Rebased to 100 at period start',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        for (final r in [TimeRange.m3, TimeRange.y1, TimeRange.y5, TimeRange.max])
                          MCChip(
                            label: r.label,
                            selected: r == range,
                            onTap: () =>
                                ref.read(_compareRangeProvider.notifier).state = r,
                          ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.vGapLg,
                SizedBox(
                  height: context.isMobile ? 240 : 340,
                  child: _NormalizedChart(ids: selected, range: range),
                ),
                AppSpacing.vGapLg,
                _Legend(ids: selected, range: range),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          _MetricsMatrix(ids: selected),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }
}

class _NormalizedChart extends StatelessWidget {
  const _NormalizedChart({required this.ids, required this.range});
  final List<String> ids;
  final TimeRange range;

  @override
  Widget build(BuildContext context) {
    final data = MockMarketData.instance;
    final bars = <LineChartBarData>[];
    double minY = 100, maxY = 100;

    for (var idx = 0; idx < ids.length; idx++) {
      final series = data.seriesForRange(ids[idx], range);
      if (series.length < 2) continue;
      final base = series.first.close;
      final spots = <FlSpot>[];
      for (var i = 0; i < series.length; i++) {
        final x = i / (series.length - 1) * 100;
        final y = series[i].close / base * 100;
        minY = y < minY ? y : minY;
        maxY = y > maxY ? y : maxY;
        spots.add(FlSpot(x, y));
      }
      final color = _compareColors[idx % _compareColors.length];
      bars.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.12,
        barWidth: 2.2,
        color: color,
        dotData: const FlDotData(show: false),
      ));
    }

    if (bars.isEmpty) {
      return const Center(child: Text('Select assets to compare'));
    }

    final pad = (maxY - minY) * 0.1;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 100,
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 3).clamp(1, double.infinity),
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: ((maxY - minY) / 3).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(value.toStringAsFixed(0),
                    style: AppTypography.mono(size: 10, color: AppColors.textTertiary)),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceHigh,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      s.y.toStringAsFixed(1),
                      AppTypography.mono(size: 11, color: AppColors.textPrimary),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: bars,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.ids, required this.range});
  final List<String> ids;
  final TimeRange range;

  @override
  Widget build(BuildContext context) {
    final data = MockMarketData.instance;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < ids.length; i++)
          Builder(builder: (context) {
            final series = data.seriesForRange(ids[i], range);
            final ret = series.length < 2
                ? 0.0
                : (series.last.close - series.first.close) / series.first.close * 100;
            final color = _compareColors[i % _compareColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 3, color: color),
                AppSpacing.hGapSm,
                Text(ids[i], style: Theme.of(context).textTheme.titleSmall),
                AppSpacing.hGapSm,
                Text(Fmt.percent(ret),
                    style: AppTypography.mono(
                        size: 12, weight: FontWeight.w600, color: AppColors.forChange(ret))),
              ],
            );
          }),
      ],
    );
  }
}

class _MetricsMatrix extends StatelessWidget {
  const _MetricsMatrix({required this.ids});
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final data = MockMarketData.instance;
    final assets = [for (final id in ids) data.assetById(id)].whereType<Asset>().toList();

    String metric(Asset a, String key) {
      final q = data.quote(a.id);
      switch (key) {
        case 'price':
          return Fmt.priceExact(q.price);
        case 'change':
          return Fmt.percent(q.changePercent);
        case 'mcap':
          return Fmt.compactCurrency(data.marketCapNow(a.id));
        default:
          final val = data.valuationAt(a.id, data.now);
          final v = val.where((m) => m.id == key).firstOrNull;
          return v?.display ?? '—';
      }
    }

    final rows = <(String, String)>[
      ('Price', 'price'),
      ('Day change', 'change'),
      ('Market cap', 'mcap'),
      ('P/E', 'pe'),
      ('P/S', 'ps'),
    ];

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SIDE BY SIDE', style: AppTypography.eyebrow()),
          AppSpacing.vGapMd,
          // Header row.
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              for (final a in assets)
                Expanded(
                  flex: 3,
                  child: Text(a.ticker,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
            ],
          ),
          const Divider(),
          for (final (label, key) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  for (final a in assets)
                    Expanded(
                      flex: 3,
                      child: Text(metric(a, key),
                          textAlign: TextAlign.right,
                          style: AppTypography.mono(
                              size: 12.5,
                              weight: FontWeight.w600,
                              color: key == 'change'
                                  ? AppColors.forChange(data.quote(a.id).changePercent)
                                  : AppColors.textPrimary)),
                    ),
                ],
              ),
            ),
          AppSpacing.vGapMd,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.go('/asset/${ids.first}'),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text('Open ${ids.first}'),
            ),
          ),
        ],
      ),
    );
  }
}

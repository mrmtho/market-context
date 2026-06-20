import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/enums.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/events.dart';
import '../../../data/models/price_point.dart';

/// The interactive price timeline (Feature 4). Renders a gradient line with an
/// area fill, hover/tap tooltips, a selected-date marker and event markers.
class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.series,
    required this.currency,
    required this.accent,
    required this.onSelectDate,
    this.selectedDate,
    this.events = const [],
    this.overlayType = ChartOverlayType.none,
    this.overlayPoints,
  });

  final PriceSeries series;
  final String currency;
  final Color accent;
  final ValueChanged<DateTime> onSelectDate;
  final DateTime? selectedDate;
  final List<NarrativeEvent> events;
  final ChartOverlayType overlayType;
  final List<double>? overlayPoints;

  Color _overlayColor(ChartOverlayType type) {
    switch (type) {
      case ChartOverlayType.eps: return AppColors.accentCyan;
      case ChartOverlayType.pe: return AppColors.accentTeal;
      case ChartOverlayType.revenue: return AppColors.accentViolet;
      case ChartOverlayType.inflation: return AppColors.accentBlue;
      case ChartOverlayType.interestRate: return AppColors.negative;
      case ChartOverlayType.gdp: return AppColors.positive;
      case ChartOverlayType.unemployment: return AppColors.warning;
      default: return Colors.grey;
    }
  }

  int? get _selectedIndex {
    if (selectedDate == null) return null;
    var best = 0;
    var bestDiff = 1 << 30;
    for (var i = 0; i < series.points.length; i++) {
      final d = series.points[i].date.difference(selectedDate!).inDays.abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = i;
      }
    }
    return best;
  }

  List<int> get _eventIndices {
    final pts = series.points;
    if (pts.isEmpty) return const [];
    final out = <int>[];
    for (final e in events) {
      if (e.date.isBefore(pts.first.date) || e.date.isAfter(pts.last.date)) {
        continue;
      }
      var best = 0;
      var bestDiff = 1 << 30;
      for (var i = 0; i < pts.length; i++) {
        final d = pts[i].date.difference(e.date).inDays.abs();
        if (d < bestDiff) {
          bestDiff = d;
          best = i;
        }
      }
      out.add(best);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final pts = series.points;
    if (pts.length < 2) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('No price data for this range')),
      );
    }

    final spots = [
      for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].close),
    ];
    final minY = series.min;
    final maxY = series.max;
    final pad = (maxY - minY) * 0.12;
    final lineColor = accent;
    final selIdx = _selectedIndex;
    final eventIdx = _eventIndices;

    final backgroundSpots = <FlSpot>[];
    if (overlayPoints != null && overlayPoints!.isNotEmpty) {
      double overlayMin = overlayPoints!.reduce((a, b) => a < b ? a : b);
      double overlayMax = overlayPoints!.reduce((a, b) => a > b ? a : b);
      final yRange = maxY - minY;
      final oRange = overlayMax - overlayMin;
      for (var i = 0; i < pts.length; i++) {
        final val = overlayPoints![i];
        double scaledY;
        if (oRange == 0) {
          scaledY = minY + yRange / 2;
        } else {
          final norm = (val - overlayMin) / oRange;
          scaledY = (minY + pad) + norm * (yRange - 2 * pad);
        }
        backgroundSpots.add(FlSpot(i.toDouble(), scaledY));
      }
    }

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        minX: 0,
        maxX: (pts.length - 1).toDouble(),
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) <= 0 ? 1 : (maxY - minY) / 3,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: (maxY - minY) <= 0 ? 1 : (maxY - minY) / 3,
              getTitlesWidget: (value, meta) {
                if (value <= minY || value >= maxY) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(Fmt.compact(value),
                      style: AppTypography.mono(
                          size: 10, color: AppColors.textTertiary)),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: ((pts.length - 1) / 4).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= pts.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(Fmt.shortDate(pts[i].date),
                      style: AppTypography.mono(
                          size: 10, color: AppColors.textTertiary)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response?.lineBarSpots == null) return;
            if (event is FlTapUpEvent ||
                event is FlPanEndEvent ||
                event is FlLongPressEnd) {
              final i = response!.lineBarSpots!.first.x.round();
              if (i >= 0 && i < pts.length) onSelectDate(pts[i].date);
            }
          },
          getTouchedSpotIndicator: (barData, indices) {
            return indices.map((i) {
              return TouchedSpotIndicatorData(
                FlLine(color: accent.withValues(alpha: 0.5), strokeWidth: 1),
                FlDotData(
                  getDotPainter: (s, _, _, _) => FlDotCirclePainter(
                    radius: 5,
                    color: accent,
                    strokeWidth: 2,
                    strokeColor: AppColors.background,
                  ),
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceHigh,
            tooltipBorder: const BorderSide(color: AppColors.borderStrong),
            tooltipRoundedRadius: 10,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                final isOverlayBar = overlayPoints != null && overlayPoints!.isNotEmpty && s.barIndex == 0;
                if (isOverlayBar) return null;
                
                final i = s.x.round().clamp(0, pts.length - 1);
                final p = pts[i];
                
                String overlayText = '';
                if (overlayType != ChartOverlayType.none && overlayPoints != null && i < overlayPoints!.length) {
                  final val = overlayPoints![i];
                  String formatted = val.toStringAsFixed(2);
                  if (overlayType == ChartOverlayType.inflation || overlayType == ChartOverlayType.interestRate || overlayType == ChartOverlayType.gdp || overlayType == ChartOverlayType.unemployment) {
                    formatted = '${val.toStringAsFixed(2)}%';
                  } else if (overlayType == ChartOverlayType.revenue) {
                    formatted = '\$${val.toStringAsFixed(1)}B';
                  } else if (overlayType == ChartOverlayType.eps) {
                    formatted = '\$${val.toStringAsFixed(2)}';
                  } else if (overlayType == ChartOverlayType.pe) {
                    formatted = '${val.toStringAsFixed(1)}×';
                  }
                  overlayText = '\n${overlayType.label}: $formatted';
                }
                
                return LineTooltipItem(
                  '${Fmt.priceExact(p.close, currency: currency)}$overlayText\n',
                  AppTypography.mono(
                      size: 13, weight: FontWeight.w700, color: AppColors.textPrimary),
                  children: [
                    TextSpan(
                      text: Fmt.date(p.date),
                      style: AppTypography.mono(
                          size: 10, color: AppColors.textSecondary),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          if (backgroundSpots.isNotEmpty)
            LineChartBarData(
              spots: backgroundSpots,
              isCurved: true,
              curveSmoothness: 0.18,
              barWidth: 1.8,
              dashArray: const [4, 4],
              color: _overlayColor(overlayType).withValues(alpha: 0.55),
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.18,
            barWidth: 2.4,
            gradient: LinearGradient(
              colors: [lineColor.withValues(alpha: 0.7), lineColor],
            ),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.28),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Event markers — invisible line, visible dots only at event points.
          if (eventIdx.isNotEmpty)
            LineChartBarData(
              spots: [
                for (final i in eventIdx) FlSpot(i.toDouble(), pts[i].close),
              ],
              barWidth: 0,
              color: Colors.transparent,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, _, _, _) => FlDotCirclePainter(
                  radius: 3.5,
                  color: AppColors.warning,
                  strokeWidth: 1.5,
                  strokeColor: AppColors.background,
                ),
              ),
            ),
          // Selected-date marker.
          if (selIdx != null)
            LineChartBarData(
              spots: [FlSpot(selIdx.toDouble(), pts[selIdx].close)],
              barWidth: 0,
              color: Colors.transparent,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, _, _, _) => FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.accentViolet,
                  strokeWidth: 2.5,
                  strokeColor: AppColors.background,
                ),
              ),
            ),
        ],
      ),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

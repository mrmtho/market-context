import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Asset classes supported by Market Context (§7.1).
enum AssetType {
  stock('Stock', Icons.show_chart_rounded),
  etf('ETF', Icons.donut_large_rounded),
  crypto('Crypto', Icons.currency_bitcoin_rounded),
  marketIndex('Index', Icons.account_balance_rounded),
  commodity('Commodity', Icons.oil_barrel_rounded),
  currency('FX', Icons.currency_exchange_rounded),
  bond('Bond', Icons.receipt_long_rounded);

  const AssetType(this.label, this.icon);
  final String label;
  final IconData icon;

  bool get isEquityLike => this == AssetType.stock || this == AssetType.etf;
}

/// Chart time ranges (Feature 4, task 3).
enum TimeRange {
  d1('1D', 1),
  w1('1W', 7),
  m1('1M', 30),
  m3('3M', 90),
  m6('6M', 182),
  y1('1Y', 365),
  y5('5Y', 365 * 5),
  max('MAX', 365 * 12);

  const TimeRange(this.label, this.days);
  final String label;
  final int days;
}

/// Predefined comparison periods (Feature 6).
enum ComparisonPeriod {
  m3('3 Months Ago', 90),
  m6('6 Months Ago', 182),
  m12('12 Months Ago', 365),
  ytd('Start of Year', -1),
  custom('Custom Date', 0);

  const ComparisonPeriod(this.label, this.days);
  final String label;
  final int days;
}

/// News / event categories (Feature 9).
enum EventCategory {
  earnings('Earnings', Icons.assessment_rounded, AppColors.accentCyan),
  macro('Macro', Icons.public_rounded, AppColors.accentBlue),
  regulation('Regulation', Icons.gavel_rounded, AppColors.warning),
  product('Product', Icons.rocket_launch_rounded, AppColors.accentViolet),
  analyst('Analyst', Icons.insights_rounded, AppColors.accentTeal),
  geopolitical('Geopolitical', Icons.travel_explore_rounded, AppColors.negative),
  sector('Sector', Icons.category_rounded, AppColors.accentMagenta),
  secFiling('SEC Filing', Icons.description_rounded, AppColors.neutral),
  youtube('YouTube Analysis', Icons.play_circle_filled_rounded, AppColors.negative),
  podcast('Podcast', Icons.mic_rounded, AppColors.accentTeal),
  community('Discussion', Icons.forum_rounded, AppColors.accentMagenta);

  const EventCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum ImpactDirection {
  positive('Bullish', AppColors.positive, Icons.trending_up_rounded),
  negative('Bearish', AppColors.negative, Icons.trending_down_rounded),
  neutral('Mixed', AppColors.neutral, Icons.trending_flat_rounded);

  const ImpactDirection(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Macro metric grouping (Feature 7).
enum MacroCategory {
  monetary('Monetary'),
  growth('Growth'),
  inflation('Inflation'),
  markets('Markets'),
  labor('Labor');

  const MacroCategory(this.label);
  final String label;
}

/// How meaningful a difference is, for color semantics in comparisons.
enum ChangeSemantic { positive, negative, neutral }

enum AppThemeMode { dark, light }

enum DataDensity {
  comfortable('Comfortable'),
  compact('Compact');

  const DataDensity(this.label);
  final String label;
}

/// Direction in which "higher is better" for a metric, so comparison coloring
/// reflects meaning rather than raw sign.
enum MetricPolarity { higherBetter, lowerBetter, neutral }

/// Chart overlay background layers (Market Context v2).
enum ChartOverlayType {
  none('None', Icons.block_rounded),
  eps('EPS', Icons.trending_up_rounded),
  pe('P/E Ratio', Icons.speed_rounded),
  revenue('Revenue', Icons.monetization_on_rounded),
  inflation('Inflation', Icons.waves_rounded),
  interestRate('Fed Rate', Icons.percent_rounded),
  gdp('GDP Growth', Icons.show_chart_rounded),
  unemployment('Unemployment', Icons.work_off_rounded);

  const ChartOverlayType(this.label, this.icon);
  final String label;
  final IconData icon;
}

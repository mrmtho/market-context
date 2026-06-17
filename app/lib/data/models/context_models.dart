import 'enums.dart';

/// A macroeconomic reading at a point in time (§7.4, Feature 7).
class MacroMetric {
  const MacroMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.value,
    required this.unit,
    required this.asOf,
    required this.region,
    required this.source,
    required this.polarity,
    required this.why,
    required this.trend,
    this.isNearest = false,
  });

  final String id;
  final String name;
  final MacroCategory category;
  final double value;
  final String unit; // e.g. '%', 'index', '$/bbl'
  final DateTime asOf;
  final String region;
  final String source;
  final MetricPolarity polarity;

  /// One-line explanation of why this metric matters for the asset.
  final String why;

  /// Recent trend for the sparkline.
  final List<double> trend;
  final bool isNearest;

  String get formattedValue {
    if (unit == '%') return '${value.toStringAsFixed(2)}%';
    if (unit == r'$/bbl') return '\$${value.toStringAsFixed(1)}';
    if (unit == 'index') return value.toStringAsFixed(1);
    return value.toStringAsFixed(2);
  }
}

/// A business fundamental (revenue, margin, EPS, etc.) (Feature 8).
class FundamentalMetric {
  const FundamentalMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.display,
    required this.fiscalPeriod,
    required this.basis, // 'TTM' or 'Q'
    required this.polarity,
    this.estimated = false,
    this.definition,
  });

  final String id;
  final String name;
  final double value;
  final String display;
  final String fiscalPeriod;
  final String basis;
  final MetricPolarity polarity;
  final bool estimated;
  final String? definition;
}

/// A valuation multiple (PE, PS, EV/EBITDA, …) (Feature 8).
class ValuationMetric {
  const ValuationMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.display,
    required this.polarity,
    this.definition,
  });

  final String id;
  final String name;
  final double value;
  final String display;
  final MetricPolarity polarity;
  final String? definition;
}

/// A market sentiment signal.
class SentimentSignal {
  const SentimentSignal({
    required this.label,
    required this.score, // -1..1
    required this.descriptor,
  });

  final String label;
  final double score;
  final String descriptor;
}

/// Everything about an asset on a particular date (§7.3, Feature 5).
class ContextSnapshot {
  const ContextSnapshot({
    required this.date,
    required this.price,
    required this.isNearest,
    required this.nearestActualDate,
    required this.macro,
    required this.fundamentals,
    required this.valuation,
    required this.sentiment,
    required this.headline,
  });

  final DateTime date;
  final double price;

  /// True when exact data for [date] was unavailable and the nearest trading
  /// day was used instead (Design Guidelines §15.2).
  final bool isNearest;
  final DateTime nearestActualDate;

  final List<MacroMetric> macro;
  final List<FundamentalMetric> fundamentals;
  final List<ValuationMetric> valuation;
  final List<SentimentSignal> sentiment;
  final String headline;
}

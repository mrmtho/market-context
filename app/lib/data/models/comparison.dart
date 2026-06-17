import 'enums.dart';

/// One labelled row in a then-vs-now comparison (Feature 6/11).
class ComparisonRow {
  const ComparisonRow({
    required this.label,
    required this.thenDisplay,
    required this.nowDisplay,
    required this.thenValue,
    required this.nowValue,
    required this.polarity,
    this.unit = '',
    this.group = 'Price',
  });

  final String label;
  final String thenDisplay;
  final String nowDisplay;
  final double thenValue;
  final double nowValue;
  final MetricPolarity polarity;
  final String unit;
  final String group;

  double get deltaAbsolute => nowValue - thenValue;
  double get deltaPercent =>
      thenValue == 0 ? 0 : (nowValue - thenValue) / thenValue.abs() * 100;

  /// Whether the change is good/bad/neutral *for the holder*, accounting for
  /// metric polarity (e.g. higher inflation reads as negative).
  ChangeSemantic get semantic {
    if (deltaAbsolute.abs() < 1e-9 || polarity == MetricPolarity.neutral) {
      return ChangeSemantic.neutral;
    }
    final up = deltaAbsolute > 0;
    final good = polarity == MetricPolarity.higherBetter ? up : !up;
    return good ? ChangeSemantic.positive : ChangeSemantic.negative;
  }
}

/// A full comparison between a prior period and now (Feature 6).
class ContextComparison {
  const ContextComparison({
    required this.thenDate,
    required this.nowDate,
    required this.periodLabel,
    required this.rows,
    required this.topDifferences,
    required this.headline,
  });

  final DateTime thenDate;
  final DateTime nowDate;
  final String periodLabel;
  final List<ComparisonRow> rows;

  /// The 3 most meaningful differences, precomputed for the summary card.
  final List<ComparisonRow> topDifferences;
  final String headline;

  List<String> get groups =>
      rows.map((r) => r.group).toSet().toList();
}

/// The last time an asset traded near today's price (Feature 11, §7).
class SamePriceMatch {
  const SamePriceMatch({
    required this.currentPrice,
    required this.matchDate,
    required this.matchPrice,
    required this.tolerancePercent,
    required this.comparison,
    required this.headline,
  });

  final double currentPrice;
  final DateTime matchDate;
  final double matchPrice;
  final double tolerancePercent;
  final ContextComparison comparison;
  final String headline;
}

/// User-adjustable assumptions for the scenario explorer (Feature 12).
class ScenarioInput {
  const ScenarioInput({
    required this.revenueGrowth, // %
    required this.netMargin, // %
    required this.exitMultiple, // P/E
    required this.discountRate, // %
    required this.years,
  });

  final double revenueGrowth;
  final double netMargin;
  final double exitMultiple;
  final double discountRate;
  final int years;

  ScenarioInput copyWith({
    double? revenueGrowth,
    double? netMargin,
    double? exitMultiple,
    double? discountRate,
    int? years,
  }) {
    return ScenarioInput(
      revenueGrowth: revenueGrowth ?? this.revenueGrowth,
      netMargin: netMargin ?? this.netMargin,
      exitMultiple: exitMultiple ?? this.exitMultiple,
      discountRate: discountRate ?? this.discountRate,
      years: years ?? this.years,
    );
  }
}

/// Result of running a scenario against a base case (Feature 12).
class ScenarioResult {
  const ScenarioResult({
    required this.impliedPrice,
    required this.currentPrice,
  });

  final double impliedPrice;
  final double currentPrice;

  double get upsidePercent =>
      currentPrice == 0 ? 0 : (impliedPrice - currentPrice) / currentPrice * 100;
}

/// A labelled preset (base / bull / bear) (Feature 12, tasks 8–10).
class ScenarioPreset {
  const ScenarioPreset(this.name, this.description, this.input);
  final String name;
  final String description;
  final ScenarioInput input;
}

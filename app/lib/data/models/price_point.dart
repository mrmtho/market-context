/// A single OHLC price observation (§7.2).
class PricePoint {
  const PricePoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
}

/// A price series for a given range plus convenience aggregates.
class PriceSeries {
  const PriceSeries({required this.points});
  final List<PricePoint> points;

  bool get isEmpty => points.isEmpty;
  double get first => points.first.close;
  double get last => points.last.close;

  double get min =>
      points.map((p) => p.low).reduce((a, b) => a < b ? a : b);
  double get max =>
      points.map((p) => p.high).reduce((a, b) => a > b ? a : b);

  double get changeAbsolute => last - first;
  double get changePercent =>
      first == 0 ? 0 : (last - first) / first * 100;

  /// Closing values only — handy for sparklines.
  List<double> get closes => points.map((p) => p.close).toList();
}

import 'dart:math';

import '../models/asset.dart';
import '../models/comparison.dart';
import '../models/context_models.dart';
import '../models/enums.dart';
import '../models/events.dart';
import '../models/narrative.dart';
import '../models/price_point.dart';
import '../models/scenario.dart';

/// Internal generation spec for a single asset.
class _Spec {
  const _Spec({
    required this.asset,
    required this.startPrice,
    required this.currentPrice,
    required this.annualVol,
    required this.sharesOutB,
    required this.revenueTtmB,
    required this.revCagr,
    required this.netMargin,
    required this.sentiment,
  });
  final Asset asset;
  final double startPrice;
  final double currentPrice;
  final double annualVol;
  final double sharesOutB; // billions of shares
  final double revenueTtmB; // billions, today (0 for non-equity)
  final double revCagr; // annual revenue growth
  final double netMargin; // 0..1
  final double sentiment; // -1..1 baseline
}

/// Deterministic mock market: stable across reloads, realistic-ish shapes.
///
/// Acts as the single source of truth that the mock API client reads from.
class MockMarketData {
  MockMarketData._();
  static final MockMarketData instance = MockMarketData._();

  /// "Now" is pinned so the generated world is reproducible.
  final DateTime now = DateTime(2026, 6, 17);
  static const int historyDays = 365 * 12;

  final Map<String, List<PricePoint>> _seriesCache = {};

  // ---- Asset catalogue -----------------------------------------------------

  late final List<_Spec> _specs = _buildSpecs();

  List<Asset> get assets => _specs.map((s) => s.asset).toList();

  _Spec _spec(String id) =>
      _specs.firstWhere((s) => s.asset.id == id, orElse: () => _specs.first);

  Asset? assetById(String id) {
    for (final s in _specs) {
      if (s.asset.id == id || s.asset.ticker.toLowerCase() == id.toLowerCase()) {
        return s.asset;
      }
    }
    return null;
  }

  List<_Spec> _buildSpecs() {
    Asset a(String ticker, String name, AssetType type, String exch,
            String country, String? sector, String? industry, int seed) =>
        Asset(
          id: ticker,
          ticker: ticker,
          displayName: name,
          assetType: type,
          exchange: exch,
          currency: type == AssetType.crypto ? 'USD' : 'USD',
          country: country,
          sector: sector,
          industry: industry,
          accentSeed: seed,
        );

    return [
      _Spec(
        asset: a('NVDA', 'NVIDIA Corporation', AssetType.stock, 'NASDAQ', 'United States',
            'Technology', 'Semiconductors', 1),
        startPrice: 4.6, currentPrice: 131.26, annualVol: 0.48,
        sharesOutB: 24.6, revenueTtmB: 96.3, revCagr: 0.32, netMargin: 0.49,
        sentiment: 0.62,
      ),
      _Spec(
        asset: a('AAPL', 'Apple Inc.', AssetType.stock, 'NASDAQ', 'United States',
            'Technology', 'Consumer Electronics', 2),
        startPrice: 18.5, currentPrice: 209.07, annualVol: 0.27,
        sharesOutB: 15.2, revenueTtmB: 385.6, revCagr: 0.11, netMargin: 0.25,
        sentiment: 0.34,
      ),
      _Spec(
        asset: a('MSFT', 'Microsoft Corporation', AssetType.stock, 'NASDAQ', 'United States',
            'Technology', 'Software', 3),
        startPrice: 37.0, currentPrice: 449.78, annualVol: 0.26,
        sharesOutB: 7.43, revenueTtmB: 245.1, revCagr: 0.14, netMargin: 0.36,
        sentiment: 0.41,
      ),
      _Spec(
        asset: a('TSLA', 'Tesla, Inc.', AssetType.stock, 'NASDAQ', 'United States',
            'Consumer Cyclical', 'Auto Manufacturers', 4),
        startPrice: 14.0, currentPrice: 178.79, annualVol: 0.58,
        sharesOutB: 3.19, revenueTtmB: 95.7, revCagr: 0.27, netMargin: 0.13,
        sentiment: 0.18,
      ),
      _Spec(
        asset: a('AMZN', 'Amazon.com, Inc.', AssetType.stock, 'NASDAQ', 'United States',
            'Consumer Cyclical', 'Internet Retail', 5),
        startPrice: 15.5, currentPrice: 185.57, annualVol: 0.31,
        sharesOutB: 10.4, revenueTtmB: 590.7, revCagr: 0.18, netMargin: 0.07,
        sentiment: 0.29,
      ),
      _Spec(
        asset: a('GOOGL', 'Alphabet Inc.', AssetType.stock, 'NASDAQ', 'United States',
            'Communication Services', 'Internet Content', 6),
        startPrice: 25.0, currentPrice: 178.35, annualVol: 0.28,
        sharesOutB: 12.3, revenueTtmB: 328.3, revCagr: 0.15, netMargin: 0.27,
        sentiment: 0.31,
      ),
      _Spec(
        asset: a('JPM', 'JPMorgan Chase & Co.', AssetType.stock, 'NYSE', 'United States',
            'Financial Services', 'Banks', 7),
        startPrice: 55.0, currentPrice: 199.95, annualVol: 0.24,
        sharesOutB: 2.87, revenueTtmB: 162.4, revCagr: 0.07, netMargin: 0.32,
        sentiment: 0.12,
      ),
      _Spec(
        asset: a('SPY', 'SPDR S&P 500 ETF Trust', AssetType.etf, 'NYSE ARCA', 'United States',
            'Index Fund', 'Large Blend', 8),
        startPrice: 168.0, currentPrice: 542.84, annualVol: 0.16,
        sharesOutB: 0.92, revenueTtmB: 0, revCagr: 0, netMargin: 0,
        sentiment: 0.22,
      ),
      _Spec(
        asset: a('QQQ', 'Invesco QQQ Trust', AssetType.etf, 'NASDAQ', 'United States',
            'Index Fund', 'Large Growth', 9),
        startPrice: 86.0, currentPrice: 479.12, annualVol: 0.20,
        sharesOutB: 0.61, revenueTtmB: 0, revCagr: 0, netMargin: 0,
        sentiment: 0.27,
      ),
      _Spec(
        asset: a('BTC', 'Bitcoin', AssetType.crypto, 'Crypto', 'Global',
            'Digital Assets', 'Store of Value', 10),
        startPrice: 800.0, currentPrice: 66250.0, annualVol: 0.72,
        sharesOutB: 0.0197, revenueTtmB: 0, revCagr: 0, netMargin: 0,
        sentiment: 0.35,
      ),
      _Spec(
        asset: a('ETH', 'Ethereum', AssetType.crypto, 'Crypto', 'Global',
            'Digital Assets', 'Smart Contracts', 11),
        startPrice: 8.0, currentPrice: 3520.0, annualVol: 0.80,
        sharesOutB: 0.120, revenueTtmB: 0, revCagr: 0, netMargin: 0,
        sentiment: 0.30,
      ),
      _Spec(
        asset: a('GLD', 'SPDR Gold Shares', AssetType.commodity, 'NYSE ARCA', 'Global',
            'Commodity', 'Precious Metals', 12),
        startPrice: 115.0, currentPrice: 216.40, annualVol: 0.14,
        sharesOutB: 0.42, revenueTtmB: 0, revCagr: 0, netMargin: 0,
        sentiment: 0.08,
      ),
    ];
  }

  // ---- Price path generation ----------------------------------------------

  /// Full daily history for an asset (cached). Uses a Brownian-bridge so the
  /// path starts at [_Spec.startPrice] and ends exactly at [currentPrice].
  List<PricePoint> fullSeries(String id) {
    final cached = _seriesCache[id];
    if (cached != null) return cached;

    final spec = _spec(id);
    final rng = Random(spec.asset.accentSeed * 7919 + 13);
    final n = historyDays;
    final dailyVol = spec.annualVol / sqrt(252);

    // Random daily log-returns.
    final cum = List<double>.filled(n, 0);
    double running = 0;
    for (var i = 0; i < n; i++) {
      running += _gauss(rng) * dailyVol;
      cum[i] = running;
    }
    final logStart = log(spec.startPrice);
    final logEnd = log(spec.currentPrice);
    final last = cum[n - 1];

    final points = <PricePoint>[];
    for (var i = 0; i < n; i++) {
      final frac = i / (n - 1);
      // Bridge: remove the linear drift of accumulated noise, then add the
      // intended start→end log ramp.
      final bridged = cum[i] - frac * last;
      final logP = logStart + (logEnd - logStart) * frac + bridged;
      final close = exp(logP);
      final date = now.subtract(Duration(days: n - 1 - i));

      final intraSpread = close * dailyVol * 0.9;
      final open = close - _gauss(rng) * intraSpread * 0.4;
      final high = max(open, close) + rng.nextDouble() * intraSpread;
      final low = min(open, close) - rng.nextDouble() * intraSpread;
      final vol = (spec.sharesOutB > 0 ? spec.sharesOutB * 1e9 : 5e8) *
          (0.004 + rng.nextDouble() * 0.01);

      points.add(PricePoint(
        date: date,
        open: open,
        high: high,
        low: max(0.01, low),
        close: close,
        volume: vol,
      ));
    }
    _seriesCache[id] = points;
    return points;
  }

  double _gauss(Random rng) {
    final u1 = rng.nextDouble().clamp(1e-9, 1.0);
    final u2 = rng.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  /// Price points within [range] (most recent slice of the full history).
  List<PricePoint> seriesForRange(String id, TimeRange range) {
    final full = fullSeries(id);
    final count = min(range.days, full.length);
    var slice = full.sublist(full.length - count);
    // Down-sample long ranges so charts stay crisp and fast.
    final maxPoints = 320;
    if (slice.length > maxPoints) {
      final step = (slice.length / maxPoints).ceil();
      slice = [
        for (var i = 0; i < slice.length; i += step) slice[i],
        slice.last,
      ];
    }
    return slice;
  }

  /// Closing price on (or nearest before) [date].
  PricePoint nearestPoint(String id, DateTime date) {
    final full = fullSeries(id);
    if (date.isBefore(full.first.date)) return full.first;
    if (date.isAfter(full.last.date)) return full.last;
    PricePoint best = full.first;
    int bestDiff = 1 << 30;
    for (final p in full) {
      final d = (p.date.difference(date).inDays).abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = p;
        if (d == 0) break;
      }
    }
    return best;
  }

  double yearsAgo(DateTime date) => now.difference(date).inDays / 365.0;

  // ---- Macro engine --------------------------------------------------------

  // Yearly anchor values 2014..2026 (index 0 == 2014).
  static const _years0 = 2014;
  static const Map<String, List<double>> _macroAnchors = {
    // CPI YoY %
    'cpi': [1.6, 0.1, 1.3, 2.1, 2.4, 1.8, 1.2, 4.7, 8.0, 4.1, 3.1, 2.6, 2.4],
    // Fed funds upper %
    'ffr': [0.25, 0.5, 0.75, 1.5, 2.5, 1.75, 0.25, 0.25, 4.5, 5.5, 4.75, 4.0, 3.75],
    // Real GDP growth %
    'gdp': [2.5, 2.9, 1.8, 2.4, 2.9, 2.3, -2.2, 5.8, 2.5, 2.9, 2.7, 2.1, 2.0],
    // Unemployment %
    'unemp': [6.2, 5.3, 4.9, 4.4, 3.9, 3.7, 8.1, 5.4, 3.6, 3.6, 4.0, 4.1, 4.2],
    // 10Y yield %
    'us10y': [2.5, 2.1, 1.8, 2.3, 2.9, 2.1, 0.9, 1.5, 3.0, 4.0, 4.3, 4.4, 4.3],
    // WTI oil $/bbl
    'oil': [93, 49, 43, 51, 65, 57, 39, 68, 95, 78, 80, 76, 73],
    // DXY dollar index
    'dxy': [88, 96, 96, 94, 95, 97, 96, 92, 104, 103, 104, 105, 103],
    // High-yield credit spread bps -> %
    'hy': [3.8, 6.6, 4.2, 3.4, 3.5, 4.0, 5.1, 3.1, 4.8, 3.9, 3.4, 3.2, 3.3],
  };

  double _interp(String key, DateTime date) {
    final arr = _macroAnchors[key]!;
    final y = date.year + (date.month - 1) / 12.0;
    final idx = (y - _years0).clamp(0, arr.length - 1.0001);
    final lo = idx.floor();
    final hi = min(lo + 1, arr.length - 1);
    final t = idx - lo;
    return arr[lo] * (1 - t) + arr[hi] * t;
  }

  List<double> _macroTrend(String key, DateTime date) {
    return [
      for (var m = 11; m >= 0; m--)
        _interp(key, DateTime(date.year, date.month - m, 1))
    ];
  }

  List<MacroMetric> macroAt(DateTime date, {String region = 'United States'}) {
    MacroMetric m(String id, String name, MacroCategory cat, String key,
            String unit, MetricPolarity pol, String why) =>
        MacroMetric(
          id: id,
          name: name,
          category: cat,
          value: _interp(key, date),
          unit: unit,
          asOf: date,
          region: region,
          source: 'Mock Macro Feed',
          polarity: pol,
          why: why,
          trend: _macroTrend(key, date),
        );

    return [
      m('cpi', 'Inflation (CPI YoY)', MacroCategory.inflation, 'cpi', '%',
          MetricPolarity.lowerBetter,
          'Higher inflation pressures real returns and can force tighter policy.'),
      m('ffr', 'Fed Funds Rate', MacroCategory.monetary, 'ffr', '%',
          MetricPolarity.lowerBetter,
          'Rates set the discount applied to future cash flows — key for valuations.'),
      m('us10y', '10Y Treasury Yield', MacroCategory.markets, 'us10y', '%',
          MetricPolarity.lowerBetter,
          'The risk-free benchmark long-duration assets are priced against.'),
      m('gdp', 'GDP Growth', MacroCategory.growth, 'gdp', '%',
          MetricPolarity.higherBetter,
          'Stronger growth supports revenues and risk appetite.'),
      m('unemp', 'Unemployment', MacroCategory.labor, 'unemp', '%',
          MetricPolarity.lowerBetter,
          'Labor strength signals consumer demand and wage pressure.'),
      m('oil', 'Crude Oil (WTI)', MacroCategory.markets, 'oil', r'$/bbl',
          MetricPolarity.neutral,
          'Energy costs feed inflation and shift sector winners and losers.'),
      m('dxy', 'US Dollar Index', MacroCategory.markets, 'dxy', 'index',
          MetricPolarity.neutral,
          'A stronger dollar weighs on commodities and overseas earnings.'),
      m('hy', 'Credit Spreads (HY)', MacroCategory.markets, 'hy', '%',
          MetricPolarity.lowerBetter,
          'Widening spreads warn of stress and tightening financial conditions.'),
    ];
  }

  // ---- Fundamentals & valuation -------------------------------------------

  List<FundamentalMetric> fundamentalsAt(String id, DateTime date) {
    final spec = _spec(id);
    if (spec.revenueTtmB <= 0) return const [];
    final ya = yearsAgo(date);
    final scale = pow(1 + spec.revCagr, -ya).toDouble();
    final revenue = spec.revenueTtmB * scale;
    final netIncome = revenue * spec.netMargin;
    final eps = netIncome / spec.sharesOutB; // $B / B shares = $/share
    final fiscalYear = date.year;
    final fp = 'FY$fiscalYear TTM';
    return [
      FundamentalMetric(
        id: 'rev', name: 'Revenue', value: revenue,
        display: '\$${revenue.toStringAsFixed(1)}B',
        fiscalPeriod: fp, basis: 'TTM', polarity: MetricPolarity.higherBetter,
        definition: 'Trailing-twelve-month total sales.',
      ),
      FundamentalMetric(
        id: 'ni', name: 'Net Income', value: netIncome,
        display: '\$${netIncome.toStringAsFixed(1)}B',
        fiscalPeriod: fp, basis: 'TTM', polarity: MetricPolarity.higherBetter,
        definition: 'Profit after all expenses and taxes.',
      ),
      FundamentalMetric(
        id: 'margin', name: 'Net Margin', value: spec.netMargin * 100,
        display: '${(spec.netMargin * 100).toStringAsFixed(1)}%',
        fiscalPeriod: fp, basis: 'TTM', polarity: MetricPolarity.higherBetter,
        definition: 'Net income as a percentage of revenue.',
      ),
      FundamentalMetric(
        id: 'eps', name: 'EPS (TTM)', value: eps,
        display: '\$${eps.toStringAsFixed(2)}',
        fiscalPeriod: fp, basis: 'TTM', polarity: MetricPolarity.higherBetter,
        definition: 'Earnings per share over the trailing twelve months.',
      ),
    ];
  }

  List<ValuationMetric> valuationAt(String id, DateTime date) {
    final spec = _spec(id);
    if (spec.revenueTtmB <= 0) return const [];
    final price = nearestPoint(id, date).close;
    final ya = yearsAgo(date);
    final scale = pow(1 + spec.revCagr, -ya).toDouble();
    final revenue = spec.revenueTtmB * scale;
    final netIncome = revenue * spec.netMargin;
    final eps = netIncome / spec.sharesOutB;
    final marketCap = price * spec.sharesOutB; // $B
    final pe = eps == 0 ? 0.0 : price / eps;
    final ps = revenue == 0 ? 0.0 : marketCap / revenue;
    final evEbitda = pe * 0.62; // rough proxy
    return [
      ValuationMetric(
        id: 'pe', name: 'P/E (TTM)', value: pe,
        display: '${pe.toStringAsFixed(1)}×',
        polarity: MetricPolarity.lowerBetter,
        definition: 'Price relative to trailing earnings.',
      ),
      ValuationMetric(
        id: 'ps', name: 'P/S (TTM)', value: ps,
        display: '${ps.toStringAsFixed(1)}×',
        polarity: MetricPolarity.lowerBetter,
        definition: 'Market cap relative to trailing revenue.',
      ),
      ValuationMetric(
        id: 'evebitda', name: 'EV/EBITDA', value: evEbitda,
        display: '${evEbitda.toStringAsFixed(1)}×',
        polarity: MetricPolarity.lowerBetter,
        definition: 'Enterprise value over operating earnings.',
      ),
      ValuationMetric(
        id: 'mcap', name: 'Market Cap', value: marketCap,
        display: '\$${marketCap.toStringAsFixed(0)}B',
        polarity: MetricPolarity.neutral,
        definition: 'Total equity value at this price.',
      ),
    ];
  }

  double marketCapNow(String id) {
    final spec = _spec(id);
    return spec.currentPrice * spec.sharesOutB * 1e9;
  }

  /// A fast synchronous quote (price + daily % change) for list rows.
  ({double price, double changePercent}) quote(String id) {
    final full = fullSeries(id);
    final last = full.last.close;
    final prev = full[full.length - 2].close;
    return (price: last, changePercent: (last - prev) / prev * 100);
  }

  // ---- Sentiment -----------------------------------------------------------

  List<SentimentSignal> sentimentAt(String id, DateTime date) {
    final spec = _spec(id);
    final rng = Random(spec.asset.accentSeed * 31 + date.year * 12 + date.month);
    double j() => (rng.nextDouble() - 0.5) * 0.5;
    final base = spec.sentiment;
    String desc(double s) => s > 0.3
        ? 'Bullish'
        : s > 0
            ? 'Constructive'
            : s > -0.3
                ? 'Cautious'
                : 'Bearish';
    final analyst = (base + j()).clamp(-1, 1).toDouble();
    final social = (base + j()).clamp(-1, 1).toDouble();
    final options = (base * 0.6 + j()).clamp(-1, 1).toDouble();
    return [
      SentimentSignal(label: 'Analyst Tone', score: analyst, descriptor: desc(analyst)),
      SentimentSignal(label: 'Social Buzz', score: social, descriptor: desc(social)),
      SentimentSignal(label: 'Options Skew', score: options, descriptor: desc(options)),
    ];
  }

  // ---- Context snapshot ----------------------------------------------------

  ContextSnapshot snapshotAt(String id, DateTime requested) {
    final p = nearestPoint(id, requested);
    final isNearest = (p.date.difference(requested).inDays).abs() > 2;
    final macro = macroAt(p.date);
    final fundamentals = fundamentalsAt(id, p.date);
    final valuation = valuationAt(id, p.date);
    final sentiment = sentimentAt(id, p.date);
    final cpi = macro.firstWhere((m) => m.id == 'cpi').value;
    final ffr = macro.firstWhere((m) => m.id == 'ffr').value;
    final headline = _snapshotHeadline(id, p, cpi, ffr, valuation);
    return ContextSnapshot(
      date: requested,
      price: p.close,
      isNearest: isNearest,
      nearestActualDate: p.date,
      macro: macro,
      fundamentals: fundamentals,
      valuation: valuation,
      sentiment: sentiment,
      headline: headline,
    );
  }

  String _snapshotHeadline(String id, PricePoint p, double cpi, double ffr,
      List<ValuationMetric> val) {
    final spec = _spec(id);
    final rateWord = ffr > 4 ? 'restrictive' : ffr > 2 ? 'moderate' : 'easy';
    final inflWord = cpi > 4 ? 'elevated' : cpi > 2.5 ? 'above-target' : 'tame';
    if (val.isNotEmpty) {
      final pe = val.firstWhere((v) => v.id == 'pe').value;
      final peWord = pe > 35 ? 'a premium' : pe > 20 ? 'a healthy' : 'a modest';
      return '${spec.asset.ticker} traded near \$${p.close.toStringAsFixed(2)} '
          'on ${p.date.year} with $inflWord inflation, $rateWord policy, and '
          '$peWord ${pe.toStringAsFixed(0)}× earnings multiple.';
    }
    return '${spec.asset.ticker} sat near \$${p.close.toStringAsFixed(2)} amid '
        '$inflWord inflation and $rateWord monetary policy.';
  }

  // ---- Comparison ----------------------------------------------------------

  ContextComparison compare(String id, DateTime thenDate, DateTime nowDate,
      String periodLabel) {
    final a = snapshotAt(id, thenDate);
    final b = snapshotAt(id, nowDate);

    final rows = <ComparisonRow>[];

    rows.add(ComparisonRow(
      label: 'Price',
      group: 'Price',
      thenValue: a.price,
      nowValue: b.price,
      thenDisplay: '\$${a.price.toStringAsFixed(2)}',
      nowDisplay: '\$${b.price.toStringAsFixed(2)}',
      polarity: MetricPolarity.higherBetter,
    ));

    // Macro rows.
    for (final mNow in b.macro) {
      final mThen = a.macro.firstWhere((x) => x.id == mNow.id);
      rows.add(ComparisonRow(
        label: mNow.name,
        group: 'Macro',
        thenValue: mThen.value,
        nowValue: mNow.value,
        thenDisplay: mThen.formattedValue,
        nowDisplay: mNow.formattedValue,
        polarity: mNow.polarity,
        unit: mNow.unit,
      ));
    }

    // Valuation rows.
    for (final vNow in b.valuation) {
      final vThen =
          a.valuation.firstWhere((x) => x.id == vNow.id, orElse: () => vNow);
      rows.add(ComparisonRow(
        label: vNow.name,
        group: 'Valuation',
        thenValue: vThen.value,
        nowValue: vNow.value,
        thenDisplay: vThen.display,
        nowDisplay: vNow.display,
        polarity: vNow.polarity,
      ));
    }

    // Fundamentals rows.
    for (final fNow in b.fundamentals) {
      final fThen =
          a.fundamentals.firstWhere((x) => x.id == fNow.id, orElse: () => fNow);
      rows.add(ComparisonRow(
        label: fNow.name,
        group: 'Fundamentals',
        thenValue: fThen.value,
        nowValue: fNow.value,
        thenDisplay: fThen.display,
        nowDisplay: fNow.display,
        polarity: fNow.polarity,
      ));
    }

    final sorted = [...rows]
      ..sort((x, y) => y.deltaPercent.abs().compareTo(x.deltaPercent.abs()));
    final top = sorted.take(3).toList();

    final priceRow = rows.first;
    final headline = _comparisonHeadline(id, priceRow, top);

    return ContextComparison(
      thenDate: a.nearestActualDate,
      nowDate: b.nearestActualDate,
      periodLabel: periodLabel,
      rows: rows,
      topDifferences: top,
      headline: headline,
    );
  }

  String _comparisonHeadline(
      String id, ComparisonRow price, List<ComparisonRow> top) {
    final dir = price.deltaPercent >= 0 ? 'up' : 'down';
    final pct = price.deltaPercent.abs().toStringAsFixed(1);
    final mover = top.firstWhere((r) => r.group != 'Price', orElse: () => top.first);
    return 'Price is $dir $pct% versus then. The biggest contextual shift is '
        '${mover.label.toLowerCase()}, now ${mover.nowDisplay} vs ${mover.thenDisplay}.';
  }

  // ---- Same-price match ----------------------------------------------------

  SamePriceMatch? samePrice(String id) {
    final full = fullSeries(id);
    final current = full.last.close;
    const tol = 0.02; // 2%
    // Walk backwards, skipping the recent window, to find the most recent
    // historical date within tolerance of today's price.
    final cutoff = full.length - 120; // at least ~4 months back
    for (var i = cutoff; i >= 0; i--) {
      final p = full[i];
      if ((p.close - current).abs() / current <= tol) {
        final matchDate = p.date;
        final comparison = compare(id, matchDate, full.last.date,
            'Last time near \$${current.toStringAsFixed(0)}');
        final headline = _samePriceHeadline(id, current, matchDate, comparison);
        return SamePriceMatch(
          currentPrice: current,
          matchDate: matchDate,
          matchPrice: p.close,
          tolerancePercent: tol * 100,
          comparison: comparison,
          headline: headline,
        );
      }
    }
    return null;
  }

  String _samePriceHeadline(
      String id, double price, DateTime matchDate, ContextComparison c) {
    final months = now.difference(matchDate).inDays ~/ 30;
    final valRow = c.rows.firstWhere((r) => r.label.startsWith('P/E'),
        orElse: () => c.rows.first);
    if (valRow.label.startsWith('P/E')) {
      final cheaper = valRow.nowValue < valRow.thenValue;
      return 'Same price, different company: ${_spec(id).asset.ticker} last '
          'traded here ~$months months ago, but it is now '
          '${cheaper ? 'cheaper' : 'more expensive'} on earnings '
          '(${valRow.nowDisplay} vs ${valRow.thenDisplay}).';
    }
    return '${_spec(id).asset.ticker} last traded near this price about '
        '$months months ago — under very different macro conditions.';
  }

  // ---- Narrative -----------------------------------------------------------

  NarrativeExplanation explain(String id, TimeRange range) {
    final spec = _spec(id);
    final series = seriesForRange(id, range);
    final change = series.isEmpty
        ? 0.0
        : (series.last.close - series.first.close) / series.first.close * 100;
    final up = change >= 0;
    final snap = snapshotAt(id, now);
    final cpi = snap.macro.firstWhere((m) => m.id == 'cpi').value;
    final ffr = snap.macro.firstWhere((m) => m.id == 'ffr').value;

    final drivers = <NarrativeDriver>[
      NarrativeDriver(
        label: spec.revenueTtmB > 0 ? 'Business growth' : 'Demand & flows',
        weight: 0.4,
        direction: up ? 1 : -1,
        detail: spec.revenueTtmB > 0
            ? 'Revenue is compounding around ${(spec.revCagr * 100).toStringAsFixed(0)}% a year, '
                'supporting earnings power into the current price.'
            : 'Net inflows and risk appetite have been the dominant force on price.',
      ),
      NarrativeDriver(
        label: 'Valuation re-rating',
        weight: 0.32,
        direction: up ? 1 : -1,
        detail: 'The multiple the market is willing to pay has '
            '${up ? 'expanded' : 'compressed'} over this window as sentiment shifted.',
      ),
      NarrativeDriver(
        label: 'Macro & rates',
        weight: 0.28,
        direction: ffr > 4 ? -1 : 1,
        detail: 'With the policy rate near ${ffr.toStringAsFixed(2)}% and inflation '
            'around ${cpi.toStringAsFixed(1)}%, the discount on future cash flows is '
            '${ffr > 4 ? 'a headwind' : 'easing'}.',
      ),
    ];

    final summary =
        '${spec.asset.ticker} is ${up ? 'up' : 'down'} ${change.abs().toStringAsFixed(1)}% '
        'over the ${range.label} window. The move looks ${up ? 'driven mostly by' : 'weighed down by a mix of'} '
        '${spec.revenueTtmB > 0 ? 'earnings momentum and a shifting valuation multiple' : 'flows and changing risk appetite'}, '
        'against a backdrop of ${ffr > 4 ? 'restrictive' : 'easing'} monetary policy.';

    final longForm =
        '$summary\n\nDecomposing the move, the largest single contributor appears to be '
        '${drivers.first.label.toLowerCase()}, followed by a ${up ? 'positive' : 'negative'} '
        'valuation re-rating. Macro conditions — chiefly the level of interest rates and '
        'the path of inflation — set the backdrop rather than acting as the proximate trigger. '
        'None of these attributions are certain; they are directional interpretations of '
        'co-moving data, not a causal proof.';

    return NarrativeExplanation(
      summary: summary,
      drivers: drivers,
      caveats: const [
        'Attribution is inferred from co-movement, not proven causation.',
        'Mock data is used for demonstration and does not reflect live markets.',
        'Past context does not predict future returns.',
      ],
      referencedData: [
        '${range.label} price change',
        'Fed Funds ${ffr.toStringAsFixed(2)}%',
        'CPI ${cpi.toStringAsFixed(1)}%',
        if (spec.revenueTtmB > 0) 'Revenue \$${spec.revenueTtmB.toStringAsFixed(0)}B TTM',
      ],
      confidence: up ? 0.68 : 0.58,
      longForm: longForm,
    );
  }

  // ---- Events --------------------------------------------------------------

  List<NarrativeEvent> events(String id) {
    final spec = _spec(id);
    final rng = Random(spec.asset.accentSeed * 104729 + 5);
    final out = <NarrativeEvent>[];

    final templates = <(EventCategory, ImpactDirection, String, String)>[
      (EventCategory.earnings, ImpactDirection.positive,
          'Quarterly results beat expectations',
          'Revenue and margins came in ahead of consensus, lifting forward estimates.'),
      (EventCategory.earnings, ImpactDirection.negative,
          'Guidance disappoints the street',
          'Management trimmed the outlook, citing softer demand and FX headwinds.'),
      (EventCategory.macro, ImpactDirection.negative,
          'Central bank signals higher-for-longer',
          'Hawkish commentary pushed yields up and pressured long-duration assets.'),
      (EventCategory.macro, ImpactDirection.positive,
          'Cooler inflation print sparks relief rally',
          'A softer CPI reading raised hopes of an earlier policy pivot.'),
      (EventCategory.product, ImpactDirection.positive,
          'New product line unveiled',
          'A well-received launch expanded the addressable market narrative.'),
      (EventCategory.analyst, ImpactDirection.positive,
          'Major broker upgrades to Buy',
          'A bulge-bracket analyst raised the rating and price target.'),
      (EventCategory.regulation, ImpactDirection.negative,
          'Regulatory probe reported',
          'Headlines around scrutiny introduced an overhang on sentiment.'),
      (EventCategory.sector, ImpactDirection.neutral,
          'Sector rotation reshuffles leadership',
          'Capital rotated across the sector, creating mixed single-name effects.'),
      (EventCategory.geopolitical, ImpactDirection.negative,
          'Geopolitical tensions rattle risk assets',
          'A flare-up in global tensions drove a broad risk-off move.'),
      (EventCategory.secFiling, ImpactDirection.neutral,
          'Form 10-K Annual Report Filed',
          'The annual report was submitted to the SEC, highlighting updated risk factors and capital structure.'),
      (EventCategory.secFiling, ImpactDirection.positive,
          'Form 4: Insider buying activity detected',
          'SEC filing shows senior executives acquired significant shares in the open market, indicating confidence.'),
      (EventCategory.youtube, ImpactDirection.positive,
          'Deep-dive analysis: AI growth narrative',
          'Prominent financial creator uploaded a visual analysis explaining the long-term margin potential.'),
      (EventCategory.youtube, ImpactDirection.neutral,
          'Is this valuation bubble territory?',
          'A popular macro analyst posted a video breaking down historical P/E multiples vs current yields.'),
      (EventCategory.podcast, ImpactDirection.neutral,
          'Macro trends and tech outlook podcast',
          'Industry veterans discussed supply chain dynamics and interest rate sensitivities affecting the stock.'),
      (EventCategory.community, ImpactDirection.positive,
          'Retail investor sentiment surges',
          'Forum discussions highlight high call option volume and bullish retail consensus around upcoming product release.'),
    ];

    // Spread ~16 events across the last 18 months.
    for (var i = 0; i < 16; i++) {
      final t = templates[rng.nextInt(templates.length)];
      final daysAgo = 20 + rng.nextInt(540);
      out.add(NarrativeEvent(
        id: '$id-evt-$i',
        date: now.subtract(Duration(days: daysAgo)),
        title: t.$3,
        source: t.$1 == EventCategory.youtube
            ? 'YouTube'
            : t.$1 == EventCategory.podcast
                ? 'Podcast Feed'
                : t.$1 == EventCategory.secFiling
                    ? 'SEC EDGAR'
                    : t.$1 == EventCategory.community
                        ? 'Reddit / X'
                        : ['Bloomberg', 'Reuters', 'WSJ', 'FT', 'CNBC'][rng.nextInt(5)],
        category: t.$1,
        impact: t.$2,
        confidence: 0.5 + rng.nextDouble() * 0.45,
        summary: t.$4,
      ));
    }
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  /// Returns the historical background metric values aligned with the price points.
  List<double> overlayValues(String id, List<PricePoint> points, ChartOverlayType type) {
    if (type == ChartOverlayType.none) return const [];
    return points.map((p) {
      switch (type) {
        case ChartOverlayType.eps:
          final funds = fundamentalsAt(id, p.date);
          if (funds.isEmpty) return 0.0;
          return funds.firstWhere((m) => m.id == 'eps', orElse: () => funds.first).value;
        case ChartOverlayType.pe:
          final vals = valuationAt(id, p.date);
          if (vals.isEmpty) return 0.0;
          return vals.firstWhere((m) => m.id == 'pe', orElse: () => vals.first).value;
        case ChartOverlayType.revenue:
          final funds = fundamentalsAt(id, p.date);
          if (funds.isEmpty) return 0.0;
          return funds.firstWhere((m) => m.id == 'rev', orElse: () => funds.first).value;
        case ChartOverlayType.inflation:
          final macro = macroAt(p.date);
          if (macro.isEmpty) return 0.0;
          return macro.firstWhere((m) => m.id == 'cpi', orElse: () => macro.first).value;
        case ChartOverlayType.interestRate:
          final macro = macroAt(p.date);
          if (macro.isEmpty) return 0.0;
          return macro.firstWhere((m) => m.id == 'ffr', orElse: () => macro.first).value;
        case ChartOverlayType.gdp:
          final macro = macroAt(p.date);
          if (macro.isEmpty) return 0.0;
          return macro.firstWhere((m) => m.id == 'gdp', orElse: () => macro.first).value;
        case ChartOverlayType.unemployment:
          final macro = macroAt(p.date);
          if (macro.isEmpty) return 0.0;
          return macro.firstWhere((m) => m.id == 'unemp', orElse: () => macro.first).value;
        default:
          return 0.0;
      }
    }).toList();
  }

  // ---- Scenario explorer ---------------------------------------------------

  /// A sensible base-case input derived from the asset's current profile.
  ScenarioInput baseScenarioInput(String id) {
    final spec = _spec(id);
    final isEquity = spec.revenueTtmB > 0;
    final val = valuationAt(id, now);
    final pe = val.isEmpty
        ? 18.0
        : val.firstWhere((v) => v.id == 'pe', orElse: () => val.first).value;
    return ScenarioInput(
      revenueGrowth: isEquity ? (spec.revCagr * 100) : 8,
      netMargin: isEquity ? (spec.netMargin * 100) : 0,
      exitMultiple: isEquity ? pe.clamp(5, 60) : 18,
      discountRate: 9,
      years: 5,
    );
  }

  List<ScenarioPreset> scenarioPresets(String id) {
    final base = baseScenarioInput(id);
    return [
      ScenarioPreset('Base', 'Trend continues', base),
      ScenarioPreset(
        'Bull',
        'Faster growth, multiple expansion',
        base.copyWith(
          revenueGrowth: base.revenueGrowth * 1.5 + 4,
          netMargin: base.netMargin * 1.15,
          exitMultiple: base.exitMultiple * 1.25,
        ),
      ),
      ScenarioPreset(
        'Bear',
        'Slower growth, multiple compression',
        base.copyWith(
          revenueGrowth: base.revenueGrowth * 0.4,
          netMargin: base.netMargin * 0.85,
          exitMultiple: base.exitMultiple * 0.7,
          discountRate: base.discountRate + 2,
        ),
      ),
    ];
  }

  /// A deliberately simple, educational implied-value model (Feature 12).
  ScenarioResult runScenario(String id, ScenarioInput input) {
    final spec = _spec(id);
    final price = spec.currentPrice;
    final g = input.revenueGrowth / 100;
    final r = input.discountRate / 100;
    if (spec.revenueTtmB > 0) {
      final eps = (spec.revenueTtmB * spec.netMargin) / spec.sharesOutB;
      final marginAdj =
          spec.netMargin > 0 ? (input.netMargin / 100) / spec.netMargin : 1.0;
      final futureEps = eps * pow(1 + g, input.years) * marginAdj;
      final terminal = futureEps * input.exitMultiple;
      final implied = terminal / pow(1 + r, input.years);
      return ScenarioResult(impliedPrice: implied, currentPrice: price);
    }
    final implied =
        price * pow(1 + g, input.years) / pow(1 + r, input.years);
    return ScenarioResult(impliedPrice: implied, currentPrice: price);
  }
}

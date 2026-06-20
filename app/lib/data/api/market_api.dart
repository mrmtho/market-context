import 'dart:math';

import '../mock/mock_market_data.dart';
import '../models/asset.dart';
import '../models/comparison.dart';
import '../models/context_models.dart';
import '../models/enums.dart';
import '../models/events.dart';
import '../models/narrative.dart';
import '../models/price_point.dart';

/// Thrown by the API layer; mapped to friendly UI errors (Feature 16/18).
class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The contract every Market Context data source must satisfy (Feature 18).
/// Swapping in a real HTTP-backed implementation later requires no UI changes.
abstract class MarketApi {
  Future<List<AssetSearchResult>> searchAssets(String query);
  Future<List<AssetSearchResult>> trendingAssets();
  Future<AssetOverview> assetOverview(String id);
  Future<PriceSeries> priceHistory(String id, TimeRange range);
  Future<ContextSnapshot> contextSnapshot(String id, DateTime date);
  Future<ContextComparison> compare(
      String id, ComparisonPeriod period, DateTime? customDate);
  Future<List<NarrativeEvent>> events(String id);
  Future<NarrativeExplanation> explanation(String id, TimeRange range);
  Future<SamePriceMatch?> samePrice(String id);
}

/// In-memory mock implementation backed by [MockMarketData], with simulated
/// latency and a small, opt-in failure rate so loading/error states are real.
class MockMarketApi implements MarketApi {
  MockMarketApi({this.failureRate = 0.0, this.latency = const Duration(milliseconds: 480)});

  final MockMarketData _data = MockMarketData.instance;
  final double failureRate;
  final Duration latency;
  final Random _rng = Random();

  Future<T> _wrap<T>(T Function() body) async {
    await Future.delayed(latency +
        Duration(milliseconds: _rng.nextInt(220)));
    if (failureRate > 0 && _rng.nextDouble() < failureRate) {
      throw const ApiException('The data service is temporarily unavailable.');
    }
    return body();
  }

  AssetSearchResult _result(Asset a) {
    final full = _data.fullSeries(a.id);
    final last = full.last.close;
    final prev = full[full.length - 2].close;
    return AssetSearchResult(
      asset: a,
      lastPrice: last,
      changePercent: (last - prev) / prev * 100,
    );
  }

  @override
  Future<List<AssetSearchResult>> searchAssets(String query) {
    return _wrap(() {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return <AssetSearchResult>[];
      final matches = _data.assets.where((a) {
        return a.ticker.toLowerCase().contains(q) ||
            a.displayName.toLowerCase().contains(q) ||
            (a.sector?.toLowerCase().contains(q) ?? false) ||
            a.assetType.label.toLowerCase().contains(q) ||
            a.exchange.toLowerCase().contains(q);
      }).map(_result).toList();
      return matches;
    });
  }

  @override
  Future<List<AssetSearchResult>> trendingAssets() {
    return _wrap(() {
      final list = _data.assets.map(_result).toList()
        ..sort((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
      return list.take(6).toList();
    });
  }

  @override
  Future<AssetOverview> assetOverview(String id) {
    return _wrap(() {
      final asset = _data.assetById(id);
      if (asset == null) throw ApiException('Asset "$id" was not found.');
      final full = _data.fullSeries(asset.id);
      final last = full.last;
      final prev = full[full.length - 2];
      final change = last.close - prev.close;
      // Intraday spark from the last ~30 closes.
      final spark = full
          .sublist(full.length - 30)
          .map((p) => p.close)
          .toList();
      return AssetOverview(
        asset: asset,
        price: last.close,
        changeAbsolute: change,
        changePercent: change / prev.close * 100,
        previousClose: prev.close,
        dayHigh: last.high,
        dayLow: last.low,
        marketCap: _data.marketCapNow(asset.id),
        volume: last.volume,
        marketOpen: _data.now.weekday <= 5,
        contextSummary: _data.snapshotAt(asset.id, _data.now).headline,
        contextScore: (75.0 + (asset.accentSeed * 17) % 20),
        asOf: last.date,
        intradaySpark: spark,
      );
    });
  }

  @override
  Future<PriceSeries> priceHistory(String id, TimeRange range) {
    return _wrap(() {
      final asset = _data.assetById(id);
      if (asset == null) throw ApiException('Asset "$id" was not found.');
      return PriceSeries(points: _data.seriesForRange(asset.id, range));
    });
  }

  @override
  Future<ContextSnapshot> contextSnapshot(String id, DateTime date) {
    return _wrap(() {
      final asset = _data.assetById(id);
      if (asset == null) throw ApiException('Asset "$id" was not found.');
      return _data.snapshotAt(asset.id, date);
    });
  }

  @override
  Future<ContextComparison> compare(
      String id, ComparisonPeriod period, DateTime? customDate) {
    return _wrap(() {
      final asset = _data.assetById(id);
      if (asset == null) throw ApiException('Asset "$id" was not found.');
      final now = _data.now;
      DateTime thenDate;
      switch (period) {
        case ComparisonPeriod.ytd:
          thenDate = DateTime(now.year, 1, 1);
          break;
        case ComparisonPeriod.custom:
          thenDate = customDate ?? now.subtract(const Duration(days: 90));
          break;
        default:
          thenDate = now.subtract(Duration(days: period.days));
      }
      return _data.compare(asset.id, thenDate, now, period.label);
    });
  }

  @override
  Future<List<NarrativeEvent>> events(String id) {
    return _wrap(() {
      final asset = _data.assetById(id);
      if (asset == null) throw ApiException('Asset "$id" was not found.');
      return _data.events(asset.id);
    });
  }

  @override
  Future<NarrativeExplanation> explanation(String id, TimeRange range) {
    return _wrap(() {
      final asset = _data.assetById(id);
      if (asset == null) throw ApiException('Asset "$id" was not found.');
      return _data.explain(asset.id, range);
    });
  }

  @override
  Future<SamePriceMatch?> samePrice(String id) {
    return _wrap(() {
      final asset = _data.assetById(id);
      if (asset == null) throw ApiException('Asset "$id" was not found.');
      return _data.samePrice(asset.id);
    });
  }
}

import '../api/market_api.dart';
import '../models/asset.dart';
import '../models/comparison.dart';
import '../models/context_models.dart';
import '../models/enums.dart';
import '../models/events.dart';
import '../models/narrative.dart';
import '../models/price_point.dart';

/// Repository abstraction over [MarketApi]. Adds light in-memory caching for
/// context snapshots (Feature 5, task 19) so re-selecting a date is instant.
class MarketRepository {
  MarketRepository(this._api);
  final MarketApi _api;

  final Map<String, ContextSnapshot> _snapshotCache = {};

  Future<List<AssetSearchResult>> search(String query) =>
      _api.searchAssets(query);

  Future<List<AssetSearchResult>> trending() => _api.trendingAssets();

  Future<AssetOverview> overview(String id) => _api.assetOverview(id);

  Future<PriceSeries> priceHistory(String id, TimeRange range) =>
      _api.priceHistory(id, range);

  Future<ContextSnapshot> snapshot(String id, DateTime date) async {
    final key = '$id@${date.toIso8601String().substring(0, 10)}';
    final cached = _snapshotCache[key];
    if (cached != null) return cached;
    final snap = await _api.contextSnapshot(id, date);
    _snapshotCache[key] = snap;
    return snap;
  }

  Future<ContextComparison> compare(
          String id, ComparisonPeriod period, DateTime? customDate) =>
      _api.compare(id, period, customDate);

  Future<List<NarrativeEvent>> events(String id) => _api.events(id);

  Future<NarrativeExplanation> explanation(String id, TimeRange range) =>
      _api.explanation(id, range);

  Future<SamePriceMatch?> samePrice(String id) => _api.samePrice(id);
}

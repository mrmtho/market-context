import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/market_api.dart';
import '../local/local_store.dart';
import '../models/asset.dart';
import '../models/comparison.dart';
import '../models/context_models.dart';
import '../models/enums.dart';
import '../models/events.dart';
import '../models/narrative.dart';
import '../models/price_point.dart';
import '../repositories/market_repository.dart';

/// Overridden in `main()` once SharedPreferences has resolved.
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider must be overridden in main()');
});

/// The active data source. A real backend would swap [MockMarketApi] here.
final marketApiProvider = Provider<MarketApi>((ref) {
  // A tiny failure rate keeps the error/retry states honest in the demo.
  return MockMarketApi(failureRate: 0.04);
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository(ref.watch(marketApiProvider));
});

// ---- Argument records for family providers ---------------------------------

typedef IdRange = ({String id, TimeRange range});
typedef IdDate = ({String id, DateTime date});
typedef IdPeriod = ({String id, ComparisonPeriod period, DateTime? customDate});

// ---- Discovery -------------------------------------------------------------

final trendingProvider = FutureProvider<List<AssetSearchResult>>((ref) {
  return ref.watch(marketRepositoryProvider).trending();
});

// ---- Asset data ------------------------------------------------------------

final overviewProvider =
    FutureProvider.family<AssetOverview, String>((ref, id) {
  return ref.watch(marketRepositoryProvider).overview(id);
});

/// Currently selected chart range, per asset.
final selectedRangeProvider =
    StateProvider.family<TimeRange, String>((ref, id) => TimeRange.y1);

final priceHistoryProvider =
    FutureProvider.family<PriceSeries, IdRange>((ref, arg) {
  return ref.watch(marketRepositoryProvider).priceHistory(arg.id, arg.range);
});

/// The date the user has selected on the chart, per asset (null = latest).
final selectedDateProvider =
    StateProvider.family<DateTime?, String>((ref, id) => null);

final snapshotProvider =
    FutureProvider.family<ContextSnapshot, IdDate>((ref, arg) {
  return ref.watch(marketRepositoryProvider).snapshot(arg.id, arg.date);
});

final comparisonProvider =
    FutureProvider.family<ContextComparison, IdPeriod>((ref, arg) {
  return ref
      .watch(marketRepositoryProvider)
      .compare(arg.id, arg.period, arg.customDate);
});

final eventsProvider =
    FutureProvider.family<List<NarrativeEvent>, String>((ref, id) {
  return ref.watch(marketRepositoryProvider).events(id);
});

final explanationProvider =
    FutureProvider.family<NarrativeExplanation, IdRange>((ref, arg) {
  return ref.watch(marketRepositoryProvider).explanation(arg.id, arg.range);
});

final samePriceProvider =
    FutureProvider.family<SamePriceMatch?, String>((ref, id) {
  return ref.watch(marketRepositoryProvider).samePrice(id);
});

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:market_context/data/local/local_store.dart';
import 'package:market_context/data/providers/providers.dart';
import 'package:market_context/data/providers/preferences_controller.dart';
import 'package:market_context/data/providers/watchlist_controller.dart';
import 'package:market_context/data/providers/insights_controller.dart';
import 'package:market_context/data/providers/search_controller.dart';
import 'package:market_context/data/mock/mock_market_data.dart';
import 'package:market_context/data/api/market_api.dart';
import 'package:market_context/data/models/enums.dart';
import 'package:market_context/data/models/user_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockMarketData Tests', () {
    final mockData = MockMarketData.instance;

    test('exposes a valid asset list', () {
      expect(mockData.assets, isNotEmpty);
      expect(mockData.assets.any((a) => a.ticker == 'NVDA'), isTrue);
      expect(mockData.assets.any((a) => a.ticker == 'BTC'), isTrue);
    });

    test('quote retrieval returns correct stats', () {
      final quote = mockData.quote('NVDA');
      expect(quote.price, isPositive);
      expect(quote.changePercent, isNotNull);
    });

    test('returns series for given range', () {
      final pts = mockData.seriesForRange('NVDA', TimeRange.m1);
      expect(pts, isNotEmpty);
      expect(pts.length, lessThanOrEqualTo(30));
    });

    test('runs scenario simulation successfully', () {
      final input = mockData.baseScenarioInput('NVDA');
      final result = mockData.runScenario('NVDA', input);
      expect(result.impliedPrice, isPositive);
      expect(result.upsidePercent, isNotNull);
    });
  });

  group('MockMarketApi Tests', () {
    late MockMarketApi api;

    setUp(() {
      api = MockMarketApi(failureRate: 0.0, latency: Duration.zero);
    });

    test('search query matches correct tickers and names', () async {
      final results = await api.searchAssets('NVIDIA');
      expect(results, isNotEmpty);
      expect(results.first.asset.ticker, equals('NVDA'));
    });

    test('trendingAssets returns top moved assets', () async {
      final trend = await api.trendingAssets();
      expect(trend, isNotEmpty);
      expect(trend.length, lessThanOrEqualTo(6));
    });

    test('assetOverview returns correct information', () async {
      final ov = await api.assetOverview('NVDA');
      expect(ov.asset.ticker, equals('NVDA'));
      expect(ov.price, isPositive);
    });
  });

  group('State Controllers Tests', () {
    late SharedPreferences sharedPrefs;
    late LocalStore localStore;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPrefs = await SharedPreferences.getInstance();
      localStore = LocalStore(sharedPrefs);

      container = ProviderContainer(
        overrides: [
          localStoreProvider.overrideWithValue(localStore),
          marketApiProvider.overrideWithValue(MockMarketApi(failureRate: 0.0, latency: Duration.zero)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('PreferencesController updates state and persists changes', () {
      final prefController = container.read(preferencesProvider.notifier);
      
      // Default state check
      expect(container.read(preferencesProvider).themeMode, equals(AppThemeMode.dark));
      
      // Update theme
      prefController.setThemeMode(AppThemeMode.light);
      expect(container.read(preferencesProvider).themeMode, equals(AppThemeMode.light));

      // Reset works
      prefController.reset();
      expect(container.read(preferencesProvider).themeMode, equals(AppThemeMode.dark));
    });

    test('WatchlistController adds and removes elements', () {
      final watchlist = container.read(watchlistProvider.notifier);
      final asset = MockMarketData.instance.assetById('NVDA')!;
      expect(container.read(watchlistProvider), isEmpty);

      // Add ticker
      watchlist.toggle(asset);
      expect(container.read(watchlistProvider).any((x) => x.assetId == 'NVDA'), isTrue);

      // Mark Viewed
      watchlist.markViewed('NVDA');
      final item = container.read(watchlistProvider).firstWhere((x) => x.assetId == 'NVDA');
      expect(item.lastViewedAt, isNotNull);

      // Remove ticker
      watchlist.toggle(asset);
      expect(container.read(watchlistProvider), isEmpty);
    });

    test('InsightsController saves and deletes snapshots', () {
      final controller = container.read(insightsProvider.notifier);
      expect(container.read(insightsProvider), isEmpty);

      final insight = SavedInsight(
        id: 'test_id',
        assetId: 'NVDA',
        ticker: 'NVDA',
        name: 'NVIDIA Corporation',
        title: 'NVIDIA context snapshot',
        body: 'NVIDIA trading at all time highs',
        kind: 'snapshot',
        referenceDate: DateTime(2026, 6, 17),
        createdAt: DateTime(2026, 6, 17),
        priceAtSave: 120.0,
      );

      controller.save(insight);
      expect(container.read(insightsProvider).length, equals(1));
      expect(container.read(insightsProvider).first.id, equals('test_id'));

      controller.remove('test_id');
      expect(container.read(insightsProvider), isEmpty);
    });

    test('SearchController yields debounced matches', () async {
      final notifier = container.read(searchControllerProvider.notifier);
      
      notifier.updateQuery('NVDA');
      // Wait for debounce duration + random delay in mock search
      await Future.delayed(const Duration(milliseconds: 800));
      
      final results = container.read(searchControllerProvider);
      results.when(
        data: (list) {
          expect(list.any((r) => r.asset.ticker == 'NVDA'), isTrue);
        },
        loading: () => fail('Search result should be resolved'),
        error: (e, _) => fail('Search should not throw: $e'),
      );
    });
  });
}

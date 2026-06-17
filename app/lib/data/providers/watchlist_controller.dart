import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/asset.dart';
import '../models/user_data.dart';
import 'providers.dart';

const _kWatchlistKey = 'watchlist_v1';

enum WatchlistSort { ticker, change, recent }

/// Manages the watchlist with optimistic local persistence (Feature 13).
class WatchlistController extends StateNotifier<List<WatchlistItem>> {
  WatchlistController(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;

  void _load() {
    final list = _ref
        .read(localStoreProvider)
        .readList(_kWatchlistKey)
        .map(WatchlistItem.fromJson)
        .toList();
    state = list;
  }

  void _persist() {
    _ref
        .read(localStoreProvider)
        .writeList(_kWatchlistKey, state.map((e) => e.toJson()).toList());
  }

  bool contains(String assetId) => state.any((e) => e.assetId == assetId);

  void toggle(Asset asset) {
    if (contains(asset.id)) {
      remove(asset.id);
    } else {
      add(asset);
    }
  }

  void add(Asset asset) {
    if (contains(asset.id)) return;
    state = [
      WatchlistItem(
        assetId: asset.id,
        ticker: asset.ticker,
        name: asset.displayName,
        addedAt: DateTime.now(),
        lastViewedAt: DateTime.now(),
      ),
      ...state,
    ];
    _persist();
  }

  void remove(String assetId) {
    state = state.where((e) => e.assetId != assetId).toList();
    _persist();
  }

  void markViewed(String assetId) {
    state = [
      for (final e in state)
        if (e.assetId == assetId) e.copyWith(lastViewedAt: DateTime.now()) else e
    ];
    _persist();
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistController, List<WatchlistItem>>((ref) {
  return WatchlistController(ref);
});

/// Current sort selection for the watchlist screen.
final watchlistSortProvider =
    StateProvider<WatchlistSort>((ref) => WatchlistSort.recent);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/asset.dart';
import '../models/enums.dart';
import 'providers.dart';

const _kRecentKey = 'recent_searches_v1';

/// Active asset-type filter chips in search (Feature 2, task 17).
final searchFilterProvider = StateProvider<Set<AssetType>>((ref) => {});

/// Recent search terms, persisted locally (Feature 2, tasks 14–16).
class RecentSearchesController extends StateNotifier<List<String>> {
  RecentSearchesController(this._ref) : super(const []) {
    state = _ref.read(localStoreProvider).readStringList(_kRecentKey);
  }
  final Ref _ref;

  void add(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    final next = [t, ...state.where((e) => e.toLowerCase() != t.toLowerCase())]
        .take(8)
        .toList();
    state = next;
    _ref.read(localStoreProvider).writeStringList(_kRecentKey, next);
  }

  void clear() {
    state = [];
    _ref.read(localStoreProvider).writeStringList(_kRecentKey, const []);
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesController, List<String>>((ref) {
  return RecentSearchesController(ref);
});

/// Debounced search query → results, with filter application (Feature 2).
class SearchController extends StateNotifier<AsyncValue<List<AssetSearchResult>>> {
  SearchController(this._ref) : super(const AsyncValue.data([]));

  final Ref _ref;
  Timer? _debounce;
  String _query = '';

  String get query => _query;

  void updateQuery(String value) {
    _query = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    _debounce = Timer(const Duration(milliseconds: 280), () => _run(value));
  }

  Future<void> _run(String value) async {
    try {
      final repo = _ref.read(marketRepositoryProvider);
      final results = await repo.search(value);
      if (!mounted || value != _query) return;
      state = AsyncValue.data(_applyFilters(results));
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  void reapplyFilters() {
    state.whenData((data) {
      // Re-run to apply filters to the latest full result set.
      if (_query.trim().isNotEmpty) _run(_query);
    });
  }

  List<AssetSearchResult> _applyFilters(List<AssetSearchResult> results) {
    final filters = _ref.read(searchFilterProvider);
    if (filters.isEmpty) return results;
    return results.where((r) => filters.contains(r.asset.assetType)).toList();
  }

  void clear() {
    _query = '';
    _debounce?.cancel();
    state = const AsyncValue.data([]);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchControllerProvider = StateNotifierProvider<SearchController,
    AsyncValue<List<AssetSearchResult>>>((ref) {
  return SearchController(ref);
});

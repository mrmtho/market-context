import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_data.dart';
import 'providers.dart';

const _kInsightsKey = 'saved_insights_v1';

/// Manages saved/shareable insights with local persistence (Feature 14).
class InsightsController extends StateNotifier<List<SavedInsight>> {
  InsightsController(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;

  void _load() {
    final list = _ref
        .read(localStoreProvider)
        .readList(_kInsightsKey)
        .map(SavedInsight.fromJson)
        .toList();
    state = list;
  }

  void _persist() {
    _ref
        .read(localStoreProvider)
        .writeList(_kInsightsKey, state.map((e) => e.toJson()).toList());
  }

  SavedInsight save(SavedInsight insight) {
    state = [insight, ...state];
    _persist();
    return insight;
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  SavedInsight? byId(String id) {
    for (final e in state) {
      if (e.id == id) return e;
    }
    return null;
  }
}

final insightsProvider =
    StateNotifierProvider<InsightsController, List<SavedInsight>>((ref) {
  return InsightsController(ref);
});

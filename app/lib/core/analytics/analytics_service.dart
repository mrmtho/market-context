import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canonical analytics event names (Feature 20).
class AnalyticsEvents {
  AnalyticsEvents._();

  static const assetSearchSubmitted = 'asset_search_submitted';
  static const assetOpened = 'asset_opened';
  static const chartDateSelected = 'chart_date_selected';
  static const timeRangeChanged = 'time_range_changed';
  static const comparisonPeriodSelected = 'comparison_period_selected';
  static const contextLayerExpanded = 'context_layer_expanded';
  static const samePriceOpened = 'same_price_comparison_opened';
  static const scenarioOpened = 'scenario_explorer_opened';
  static const watchlistChanged = 'watchlist_changed';
  static const insightSaved = 'insight_saved';
  static const insightShared = 'insight_shared';
  static const explanationFeedback = 'explanation_feedback';
  static const apiFailure = 'api_failure';
}

/// Abstraction so production analytics can be swapped in without touching UI.
abstract class AnalyticsService {
  void log(String event, [Map<String, Object?> params]);
}

/// Privacy-safe debug implementation: logs to console in debug builds only,
/// and strips anything that isn't a primitive value.
class DebugAnalyticsService implements AnalyticsService {
  final List<({String event, Map<String, Object?> params})> history = [];

  @override
  void log(String event, [Map<String, Object?> params = const {}]) {
    final safe = <String, Object?>{};
    params.forEach((k, v) {
      if (v is num || v is String || v is bool || v == null) safe[k] = v;
    });
    history.add((event: event, params: safe));
    if (kDebugMode) {
      debugPrint('analytics ▸ $event ${safe.isEmpty ? '' : safe}');
    }
  }
}

/// No-op implementation for tests / disabled telemetry.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();
  @override
  void log(String event, [Map<String, Object?> params = const {}]) {}
}

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return DebugAnalyticsService();
});

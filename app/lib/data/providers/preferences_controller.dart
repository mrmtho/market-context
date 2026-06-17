import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/user_data.dart';
import 'providers.dart';

const _kPrefsKey = 'user_preferences_v1';

/// Holds [UserPreferences], persisting every change locally (Feature 17).
class PreferencesController extends StateNotifier<UserPreferences> {
  PreferencesController(this._ref) : super(const UserPreferences()) {
    _load();
  }

  final Ref _ref;

  void _load() {
    final map = _ref.read(localStoreProvider).readMap(_kPrefsKey);
    if (map != null) state = UserPreferences.fromJson(map);
  }

  void _persist() {
    _ref.read(localStoreProvider).writeMap(_kPrefsKey, state.toJson());
  }

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _persist();
  }

  void setCurrency(String currency) {
    state = state.copyWith(currency: currency);
    _persist();
  }

  void setDefaultRange(TimeRange range) {
    state = state.copyWith(defaultRange: range);
    _persist();
  }

  void setMacroRegion(String region) {
    state = state.copyWith(macroRegion: region);
    _persist();
  }

  void setDensity(DataDensity density) {
    state = state.copyWith(density: density);
    _persist();
  }

  void reset() {
    state = const UserPreferences();
    _persist();
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesController, UserPreferences>((ref) {
  return PreferencesController(ref);
});

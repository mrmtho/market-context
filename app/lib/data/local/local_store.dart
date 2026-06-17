import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for JSON-list persistence
/// (watchlist, saved insights, preferences). Feature 13/14/17.
class LocalStore {
  LocalStore(this._prefs);
  final SharedPreferences _prefs;

  static Future<LocalStore> create() async =>
      LocalStore(await SharedPreferences.getInstance());

  List<Map<String, dynamic>> readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? readMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> writeStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  List<String> readStringList(String key) =>
      _prefs.getStringList(key) ?? const [];
}

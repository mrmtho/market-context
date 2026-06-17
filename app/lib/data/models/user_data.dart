import 'enums.dart';

/// A saved asset in the watchlist (Feature 13). Persisted locally.
class WatchlistItem {
  const WatchlistItem({
    required this.assetId,
    required this.ticker,
    required this.name,
    required this.addedAt,
    this.lastViewedAt,
  });

  final String assetId;
  final String ticker;
  final String name;
  final DateTime addedAt;
  final DateTime? lastViewedAt;

  WatchlistItem copyWith({DateTime? lastViewedAt}) => WatchlistItem(
        assetId: assetId,
        ticker: ticker,
        name: name,
        addedAt: addedAt,
        lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      );

  Map<String, dynamic> toJson() => {
        'assetId': assetId,
        'ticker': ticker,
        'name': name,
        'addedAt': addedAt.toIso8601String(),
        'lastViewedAt': lastViewedAt?.toIso8601String(),
      };

  factory WatchlistItem.fromJson(Map<String, dynamic> j) => WatchlistItem(
        assetId: j['assetId'] as String,
        ticker: j['ticker'] as String,
        name: j['name'] as String,
        addedAt: DateTime.parse(j['addedAt'] as String),
        lastViewedAt: j['lastViewedAt'] == null
            ? null
            : DateTime.parse(j['lastViewedAt'] as String),
      );
}

/// A saved/shareable contextual insight (Feature 14). Persisted locally.
class SavedInsight {
  const SavedInsight({
    required this.id,
    required this.assetId,
    required this.ticker,
    required this.name,
    required this.title,
    required this.body,
    required this.kind, // 'snapshot' | 'comparison' | 'same-price'
    required this.referenceDate,
    required this.createdAt,
    this.priceAtSave,
  });

  final String id;
  final String assetId;
  final String ticker;
  final String name;
  final String title;
  final String body;
  final String kind;
  final DateTime referenceDate;
  final DateTime createdAt;
  final double? priceAtSave;

  Map<String, dynamic> toJson() => {
        'id': id,
        'assetId': assetId,
        'ticker': ticker,
        'name': name,
        'title': title,
        'body': body,
        'kind': kind,
        'referenceDate': referenceDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'priceAtSave': priceAtSave,
      };

  factory SavedInsight.fromJson(Map<String, dynamic> j) => SavedInsight(
        id: j['id'] as String,
        assetId: j['assetId'] as String,
        ticker: j['ticker'] as String,
        name: j['name'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        kind: j['kind'] as String,
        referenceDate: DateTime.parse(j['referenceDate'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        priceAtSave: (j['priceAtSave'] as num?)?.toDouble(),
      );
}

/// User display preferences (Feature 17). Persisted locally.
class UserPreferences {
  const UserPreferences({
    this.themeMode = AppThemeMode.dark,
    this.currency = 'USD',
    this.defaultRange = TimeRange.y1,
    this.macroRegion = 'United States',
    this.density = DataDensity.comfortable,
  });

  final AppThemeMode themeMode;
  final String currency;
  final TimeRange defaultRange;
  final String macroRegion;
  final DataDensity density;

  UserPreferences copyWith({
    AppThemeMode? themeMode,
    String? currency,
    TimeRange? defaultRange,
    String? macroRegion,
    DataDensity? density,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      defaultRange: defaultRange ?? this.defaultRange,
      macroRegion: macroRegion ?? this.macroRegion,
      density: density ?? this.density,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'currency': currency,
        'defaultRange': defaultRange.name,
        'macroRegion': macroRegion,
        'density': density.name,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> j) => UserPreferences(
        themeMode: AppThemeMode.values.byName(
            (j['themeMode'] as String?) ?? 'dark'),
        currency: (j['currency'] as String?) ?? 'USD',
        defaultRange:
            TimeRange.values.byName((j['defaultRange'] as String?) ?? 'y1'),
        macroRegion: (j['macroRegion'] as String?) ?? 'United States',
        density: DataDensity.values.byName((j['density'] as String?) ?? 'comfortable'),
      );
}

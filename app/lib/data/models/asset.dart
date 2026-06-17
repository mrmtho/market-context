import 'enums.dart';

/// A tradeable asset (§7.1).
class Asset {
  const Asset({
    required this.id,
    required this.ticker,
    required this.displayName,
    required this.assetType,
    required this.exchange,
    required this.currency,
    required this.country,
    this.sector,
    this.industry,
    this.logoText,
    required this.accentSeed,
  });

  final String id;
  final String ticker;
  final String displayName;
  final AssetType assetType;
  final String exchange;
  final String currency;
  final String country;
  final String? sector;
  final String? industry;

  /// Short text used to render a logo placeholder (1–2 chars).
  final String? logoText;

  /// Deterministic seed so each asset gets a stable accent color.
  final int accentSeed;

  String get avatarText =>
      logoText ?? ticker.substring(0, ticker.length >= 2 ? 2 : 1);
}

/// A lightweight search hit (Feature 2, task 1).
class AssetSearchResult {
  const AssetSearchResult({
    required this.asset,
    required this.lastPrice,
    required this.changePercent,
  });

  final Asset asset;
  final double lastPrice;
  final double changePercent;
}

/// Everything the dashboard header needs at a glance (Feature 3, task 1).
class AssetOverview {
  const AssetOverview({
    required this.asset,
    required this.price,
    required this.changeAbsolute,
    required this.changePercent,
    required this.previousClose,
    required this.dayHigh,
    required this.dayLow,
    required this.marketCap,
    required this.volume,
    required this.marketOpen,
    required this.contextSummary,
    required this.asOf,
    required this.intradaySpark,
  });

  final Asset asset;
  final double price;
  final double changeAbsolute;
  final double changePercent;
  final double previousClose;
  final double dayHigh;
  final double dayLow;
  final double marketCap;
  final double volume;
  final bool marketOpen;
  final String contextSummary;
  final DateTime asOf;
  final List<double> intradaySpark;
}

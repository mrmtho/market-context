import 'enums.dart';

/// A significant event linked to price movement (§7.5, Feature 9).
class NarrativeEvent {
  const NarrativeEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.source,
    required this.category,
    required this.impact,
    required this.confidence, // 0..1
    required this.summary,
    this.url,
  });

  final String id;
  final DateTime date;
  final String title;
  final String source;
  final EventCategory category;
  final ImpactDirection impact;
  final double confidence;
  final String summary;
  final String? url;

  String get confidenceLabel {
    if (confidence >= 0.75) return 'High confidence';
    if (confidence >= 0.5) return 'Moderate confidence';
    return 'Low confidence';
  }
}

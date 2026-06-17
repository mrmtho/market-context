/// A single attributed driver of a price move (Feature 10).
class NarrativeDriver {
  const NarrativeDriver({
    required this.label,
    required this.weight, // 0..1 relative contribution
    required this.direction, // -1, 0, 1
    required this.detail,
  });

  final String label;
  final double weight;
  final int direction;
  final String detail;
}

/// An AI-generated, non-advice explanation of price/context change (Feature 10).
class NarrativeExplanation {
  const NarrativeExplanation({
    required this.summary,
    required this.drivers,
    required this.caveats,
    required this.referencedData,
    required this.confidence, // 0..1
    required this.longForm,
  });

  final String summary;
  final List<NarrativeDriver> drivers;
  final List<String> caveats;
  final List<String> referencedData;
  final double confidence;
  final String longForm;

  String get confidenceFraming {
    if (confidence >= 0.75) return 'Likely';
    if (confidence >= 0.5) return 'Plausible';
    return 'Speculative';
  }

  static const disclaimer =
      'Market Context explanations are AI-generated interpretations for '
      'educational purposes only and are not financial advice.';
}

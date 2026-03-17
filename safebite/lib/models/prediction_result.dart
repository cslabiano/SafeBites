class PredictionResult {
  final String label;
  final double confidence;
  final List<String> allergens;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.allergens,
  });
}

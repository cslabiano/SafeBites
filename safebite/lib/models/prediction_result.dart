class PredictionResult {
  final String label;
  final double confidence;
  final List<String> allergens;
  final List<String> ingredients;
  final String? sourceLink;
  final bool foundInDatabase;

  PredictionResult({
    required this.label,
    required this.confidence,
    this.allergens = const [],
    this.ingredients = const [],
    this.sourceLink,
    this.foundInDatabase = false,
  });

  PredictionResult copyWith({
    String? label,
    double? confidence,
    List<String>? allergens,
    List<String>? ingredients,
    String? sourceLink,
    bool? foundInDatabase,
  }) {
    return PredictionResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      allergens: allergens ?? this.allergens,
      ingredients: ingredients ?? this.ingredients,
      sourceLink: sourceLink ?? this.sourceLink,
      foundInDatabase: foundInDatabase ?? this.foundInDatabase,
    );
  }
}

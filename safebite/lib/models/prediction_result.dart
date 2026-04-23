class PredictionResult {
  final String label;
  final double confidence;
  final List<String> allergens;
  final List<String> ingredients;
  final String? sourceLink;
  final bool foundInDatabase;
  final BoundingBox? boundingBox;

  PredictionResult({
    required this.label,
    required this.confidence,
    this.allergens = const [],
    this.ingredients = const [],
    this.sourceLink,
    this.foundInDatabase = false,
    this.boundingBox,
  });

  PredictionResult copyWith({
    String? label,
    double? confidence,
    List<String>? allergens,
    List<String>? ingredients,
    String? sourceLink,
    bool? foundInDatabase,
    BoundingBox? boundingBox,
  }) {
    return PredictionResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      allergens: allergens ?? this.allergens,
      ingredients: ingredients ?? this.ingredients,
      sourceLink: sourceLink ?? this.sourceLink,
      foundInDatabase: foundInDatabase ?? this.foundInDatabase,
      boundingBox: boundingBox ?? this.boundingBox,
    );
  }
}

class BoundingBox {
  final double x1, y1, x2, y2;

  BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });
}

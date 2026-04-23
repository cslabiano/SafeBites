import 'dart:ui';

class BoundingBox {
  /// Normalized coordinates [0, 1] relative to the input image size.
  final double x1, y1, x2, y2;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });
}

class PredictionResult {
  final String label;
  final double confidence;
  final List<String> allergens;
  final List<String> ingredients;
  final String? sourceLink;
  final bool foundInDatabase;

  /// Normalized bounding box [0,1]. Null when not detected by the model.
  final BoundingBox? boundingBox;

  /// Segmentation mask polygon points (normalized [0,1]).
  /// Each Offset is (x, y). Empty when the model returns no mask.
  final List<Offset> maskPoints;

  PredictionResult({
    required this.label,
    required this.confidence,
    this.allergens = const [],
    this.ingredients = const [],
    this.sourceLink,
    this.foundInDatabase = false,
    this.boundingBox,
    this.maskPoints = const [],
  });

  PredictionResult copyWith({
    String? label,
    double? confidence,
    List<String>? allergens,
    List<String>? ingredients,
    String? sourceLink,
    bool? foundInDatabase,
    BoundingBox? boundingBox,
    List<Offset>? maskPoints,
  }) {
    return PredictionResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      allergens: allergens ?? this.allergens,
      ingredients: ingredients ?? this.ingredients,
      sourceLink: sourceLink ?? this.sourceLink,
      foundInDatabase: foundInDatabase ?? this.foundInDatabase,
      boundingBox: boundingBox ?? this.boundingBox,
      maskPoints: maskPoints ?? this.maskPoints,
    );
  }
}
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import '../models/prediction_result.dart';
import 'database_service.dart';

class FoodDetectorService {
  YOLO? _yolo;
  List<String> _labels = [];

  static const double _confThreshold = 0.45;
  static const double _iouThreshold = 0.45;
  static const int _maxDetections = 5;

  // ── Per-class colour palette ──────────────────────────────────────────────
  static const List<int> _palette = [
    0xFF4E9AF1,
    0xFFE05C5C,
    0xFF5CE06E,
    0xFFE0B05C,
    0xFF9D5CE0,
    0xFF5CE0D4,
    0xFFE05CB8,
    0xFFC0E05C,
  ];

  static ui.Color colorForClass(int index) =>
      ui.Color(_palette[index % _palette.length]);

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> loadModel() async {
    // Load label list so we can map classIndex → food name.
    final labelData =
        await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelData
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // ultralytics_yolo v0.2.x: single YOLO class, one import.
    // modelPath is the full asset path as declared in pubspec.yaml.
    _yolo = YOLO(
      modelPath: 'assets/models/best_float32.tflite',
      task: YOLOTask.segment,
    );

    await _yolo!.loadModel();
  }

  // ── Inference ─────────────────────────────────────────────────────────────

  Future<FoodDetectionOutput> predict(File imageFile) async {
    if (_yolo == null) throw Exception('Model not loaded');

    final Uint8List imageBytes = await imageFile.readAsBytes();

    // predict() returns Map<String, dynamic>:
    //   'boxes'          → List of detection maps
    //   'annotatedImage' → Uint8List of image with overlays drawn natively
    final Map<String, dynamic> raw = await _yolo!.predict(
      imageBytes,
      confidenceThreshold: _confThreshold,
      iouThreshold: _iouThreshold,
    );

    // ── Annotated image ───────────────────────────────────────────────────
    final Uint8List? annotatedBytes =
        raw['annotatedImage'] as Uint8List?;

    // ── Parse detection boxes ─────────────────────────────────────────────
    final List<dynamic> rawBoxes =
        (raw['boxes'] as List<dynamic>?) ?? [];

    final sorted = rawBoxes
        .cast<Map<String, dynamic>>()
        .where((b) =>
            ((b['confidence'] as num?)?.toDouble() ?? 0) >= _confThreshold)
        .toList()
      ..sort((a, b) => ((b['confidence'] as num).toDouble())
          .compareTo((a['confidence'] as num).toDouble()));
    final top = sorted.take(_maxDetections).toList();

    final dbService = DatabaseService();
    final results = <PredictionResult>[];

    for (int i = 0; i < top.length; i++) {
      final box = top[i];

      // ── Class label ──────────────────────────────────────────────────
      final classIdx = (box['classIndex'] as num?)?.toInt() ?? 0;
      final String label = (classIdx >= 0 && classIdx < _labels.length)
          ? _labels[classIdx]
          : (box['className'] as String? ?? 'Unknown');

      final double confidence =
          (box['confidence'] as num?)?.toDouble() ?? 0;

      // ── Bounding box (normalised 0–1) ────────────────────────────────
      // The plugin may use 'x1/y1/x2/y2' or 'left/top/right/bottom'.
      BoundingBox? bbox;
      if (box.containsKey('x1')) {
        bbox = BoundingBox(
          x1: (box['x1'] as num).toDouble().clamp(0.0, 1.0),
          y1: (box['y1'] as num).toDouble().clamp(0.0, 1.0),
          x2: (box['x2'] as num).toDouble().clamp(0.0, 1.0),
          y2: (box['y2'] as num).toDouble().clamp(0.0, 1.0),
        );
      } else if (box.containsKey('left')) {
        bbox = BoundingBox(
          x1: (box['left'] as num).toDouble().clamp(0.0, 1.0),
          y1: (box['top'] as num).toDouble().clamp(0.0, 1.0),
          x2: (box['right'] as num).toDouble().clamp(0.0, 1.0),
          y2: (box['bottom'] as num).toDouble().clamp(0.0, 1.0),
        );
      }

      // ── Mask polygon (normalised 0–1) ────────────────────────────────
      // The plugin surfaces mask contour as 'maskPoints': List<[x, y]>
      List<ui.Offset> maskPoints = const [];
      final rawMask = box['maskPoints'];
      if (rawMask is List && rawMask.isNotEmpty) {
        maskPoints = rawMask
            .cast<List<dynamic>>()
            .map((pt) => ui.Offset(
                  (pt[0] as num).toDouble().clamp(0.0, 1.0),
                  (pt[1] as num).toDouble().clamp(0.0, 1.0),
                ))
            .toList();
      }

      // ── DB enrichment ────────────────────────────────────────────────
      final dbResult = await dbService.queryFood(label);

      results.add(PredictionResult(
        label: label,
        confidence: confidence,
        ingredients: dbResult?.ingredients ?? [],
        allergens: dbResult?.allergens ?? [],
        foundInDatabase: dbResult != null,
        boundingBox: bbox,
        maskPoints: maskPoints,
      ));
    }

    return FoodDetectionOutput(
      results: results,
      annotatedImageBytes: annotatedBytes,
    );
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  void close() {
    _yolo?.dispose();
    _yolo = null;
  }
}

/// Bundles prediction results with the optional natively-annotated image
/// produced by the ultralytics plugin (boxes + masks already drawn).
class FoodDetectionOutput {
  final List<PredictionResult> results;

  /// Pre-rendered image bytes with overlays. Null if no detections.
  final Uint8List? annotatedImageBytes;

  const FoodDetectionOutput({
    required this.results,
    this.annotatedImageBytes,
  });
}
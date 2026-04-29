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

  // The model always runs on a 640×640 input. Every coordinate the plugin
  // returns is in that space, so we always divide by 640 to normalise.
  static const double _inferenceSize = 640.0;

  Future<void> loadModel() async {
    final labelData = await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelData
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    _yolo = YOLO(
      modelPath: 'best_float32.tflite',
      task: YOLOTask.segment,
    );

    await _yolo!.loadModel();
  }

  /// Resize the photo to exactly 640×640 — the same pre-processing the model
  /// expects. If we only fix the width (as before), portrait images end up
  /// taller than 640 px and all Y-coordinates come back in that taller space,
  /// but we still divide by 640, so every box is shifted downward.
  Future<Uint8List> _resizeImageForInference(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _inferenceSize.toInt(),
      targetHeight: _inferenceSize.toInt(),
    );

    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) return bytes;
    return byteData.buffer.asUint8List();
  }

  Future<FoodDetectionOutput> predict(File imageFile) async {
    if (_yolo == null) throw Exception('Model not loaded');

    final Uint8List imageBytes = await _resizeImageForInference(imageFile);

    final stopwatch = Stopwatch()..start();
    final Map<String, dynamic> raw = await _yolo!.predict(
      imageBytes,
      confidenceThreshold: _confThreshold,
      iouThreshold: _iouThreshold,
    );
    stopwatch.stop();
    print('!!! Inference time: ${stopwatch.elapsedMilliseconds} ms');

    final Uint8List? maskPngBytes = raw['mask'] as Uint8List?;
    final Uint8List? annotatedBytes = raw['annotatedImage'] as Uint8List?;

    final List<dynamic> rawBoxes = (raw['boxes'] as List<dynamic>?) ?? [];

    final sorted = rawBoxes
        .cast<Map<String, dynamic>>()
        .where((b) =>
            ((b['confidence'] as num?)?.toDouble() ?? 0) >= _confThreshold)
        .toList()
      ..sort((a, b) => ((b['confidence'] as num?)?.toDouble() ?? 0)
          .compareTo(((a['confidence'] as num?)?.toDouble() ?? 0)));

    final top = sorted.take(_maxDetections).toList();

    final dbService = DatabaseService();
    final results = <PredictionResult>[];

    for (final box in top) {
      final String label = _getLabelFromBox(box);
      final double confidence = (box['confidence'] as num?)?.toDouble() ?? 0.0;
      final BoundingBox? bbox = _getNormalizedBoundingBox(box);

      final dbResult = await dbService.queryFood(label);

      results.add(
        PredictionResult(
          label: label,
          confidence: confidence,
          ingredients: dbResult?.ingredients ?? [],
          allergens: dbResult?.allergens ?? [],
          foundInDatabase: dbResult != null,
          boundingBox: bbox,
          maskPoints: const [],
        ),
      );
    }

    return FoodDetectionOutput(
      results: results,
      annotatedImageBytes: annotatedBytes,
      maskPngBytes: maskPngBytes,
      imageWidth: _inferenceSize,
      imageHeight: _inferenceSize,
    );
  }

  String _getLabelFromBox(Map<String, dynamic> box) {
    final rawClassName = box['className'];
    if (rawClassName is String && rawClassName.trim().isNotEmpty) {
      return rawClassName.trim();
    }

    final rawClass = box['class'];

    if (rawClass is int) {
      return rawClass >= 0 && rawClass < _labels.length
          ? _labels[rawClass]
          : 'Unknown';
    }

    if (rawClass is double) {
      final index = rawClass.toInt();
      return index >= 0 && index < _labels.length ? _labels[index] : 'Unknown';
    }

    if (rawClass is String && rawClass.trim().isNotEmpty) {
      return rawClass.trim();
    }

    return 'Unknown';
  }

  /// The plugin returns coordinates in the inference image's pixel space
  /// (always 640×640 after the fix above). Divide by 640 to get [0..1].
  BoundingBox? _getNormalizedBoundingBox(Map<String, dynamic> box) {
    double? x1;
    double? y1;
    double? x2;
    double? y2;

    if (box.containsKey('x1')) {
      x1 = (box['x1'] as num).toDouble();
      y1 = (box['y1'] as num).toDouble();
      x2 = (box['x2'] as num).toDouble();
      y2 = (box['y2'] as num).toDouble();
    } else if (box.containsKey('left')) {
      x1 = (box['left'] as num).toDouble();
      y1 = (box['top'] as num).toDouble();
      x2 = (box['right'] as num).toDouble();
      y2 = (box['bottom'] as num).toDouble();
    }

    if (x1 == null || y1 == null || x2 == null || y2 == null) return null;

    // Both axes are now in 640-space (width AND height were fixed to 640).
    return BoundingBox(
      x1: (x1 / _inferenceSize).clamp(0.0, 1.0),
      y1: (y1 / _inferenceSize).clamp(0.0, 1.0),
      x2: (x2 / _inferenceSize).clamp(0.0, 1.0),
      y2: (y2 / _inferenceSize).clamp(0.0, 1.0),
    );
  }

  void close() {
    _yolo?.dispose();
    _yolo = null;
  }
}

class FoodDetectionOutput {
  final List<PredictionResult> results;
  final Uint8List? annotatedImageBytes;
  final Uint8List? maskPngBytes;
  final double imageWidth;
  final double imageHeight;

  const FoodDetectionOutput({
    required this.results,
    this.annotatedImageBytes,
    this.maskPngBytes,
    required this.imageWidth,
    required this.imageHeight,
  });
}
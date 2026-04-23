import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/prediction_result.dart';
import 'database_service.dart';

class FoodDetectorService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  static const int _inputSize = 640;
  static const double _confThreshold = 0.45;
  static const double _iouThreshold = 0.45;
  static const int _maxDetections = 5;

  Future<void> loadModel() async {
    final labelData = await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelData
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    _interpreter = await Interpreter.fromAsset(
      'assets/models/best_float32.tflite',
      options: InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false,
    );

    _interpreter!.allocateTensors();
  }

  Future<List<PredictionResult>> predict(File imageFile) async {
    if (_interpreter == null) throw Exception('Model not loaded');

    final rawBytes = await imageFile.readAsBytes();
    final original = img.decodeImage(rawBytes);
    if (original == null) throw Exception('Could not decode image');

    final origW = original.width;
    final origH = original.height;

    // Letterbox instead of stretching.
    final scale = min(_inputSize / origW, _inputSize / origH);
    final resizedW = (origW * scale).round();
    final resizedH = (origH * scale).round();
    final padX = ((_inputSize - resizedW) / 2).floor();
    final padY = ((_inputSize - resizedH) / 2).floor();

    final resized = img.copyResize(
      original,
      width: resizedW,
      height: resizedH,
      interpolation: img.Interpolation.linear,
    );

    final letterboxed = img.Image(
      width: _inputSize,
      height: _inputSize,
      numChannels: 3,
    );
    img.fill(letterboxed, color: img.ColorRgb8(114, 114, 114));
    img.compositeImage(letterboxed, resized, dstX: padX, dstY: padY);

    final inputTensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = letterboxed.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    final outputDetails = _interpreter!.getOutputTensors();
    final out0Shape = outputDetails[0].shape;
    final out1Shape = outputDetails[1].shape;

    final output0 = _buildOutputBuffer(out0Shape);
    final output1 = _buildOutputBuffer(out1Shape);

    _interpreter!.runForMultipleInputs(
      [inputTensor],
      {0: output0, 1: output1},
    );

    return await _postProcess(
      output0,
      out0Shape,
      resizedW: resizedW,
      resizedH: resizedH,
      padX: padX,
      padY: padY,
    );
  }

  dynamic _buildOutputBuffer(List<int> shape) {
    if (shape.length == 1) {
      return List<double>.filled(shape[0], 0.0);
    }
    return List<dynamic>.generate(
      shape[0],
      (_) => _buildOutputBuffer(shape.sublist(1)),
    );
  }

  Future<List<PredictionResult>> _postProcess(
    dynamic rawOutput,
    List<int> shape, {
    required int resizedW,
    required int resizedH,
    required int padX,
    required int padY,
  }) async {
    final batch = rawOutput[0];
    final numClasses = _labels.length;
    final detections = <_Detection>[];

    final bool anchorsLast = shape[1] < shape[2];

    if (anchorsLast) {
      final numAnchors = (batch[0] as List).length;
      for (int a = 0; a < numAnchors; a++) {
        double maxConf = 0;
        int maxIdx = -1;

        for (int c = 0; c < numClasses; c++) {
          final score = (batch[4 + c] as List)[a] as double;
          if (score > maxConf) {
            maxConf = score;
            maxIdx = c;
          }
        }

        if (maxConf >= _confThreshold && maxIdx >= 0) {
          detections.add(_Detection(
            classIdx: maxIdx,
            confidence: maxConf,
            cx: (batch[0] as List)[a] as double,
            cy: (batch[1] as List)[a] as double,
            w: (batch[2] as List)[a] as double,
            h: (batch[3] as List)[a] as double,
          ));
        }
      }
    } else {
      final numAnchors = (batch as List).length;
      for (int a = 0; a < numAnchors; a++) {
        final anchor = batch[a] as List;
        double maxConf = 0;
        int maxIdx = -1;

        for (int c = 0; c < numClasses; c++) {
          final score = anchor[4 + c] as double;
          if (score > maxConf) {
            maxConf = score;
            maxIdx = c;
          }
        }

        if (maxConf >= _confThreshold && maxIdx >= 0) {
          detections.add(_Detection(
            classIdx: maxIdx,
            confidence: maxConf,
            cx: anchor[0] as double,
            cy: anchor[1] as double,
            w: anchor[2] as double,
            h: anchor[3] as double,
          ));
        }
      }
    }

    final kept = _nms(detections);
    kept.sort((a, b) => b.confidence.compareTo(a.confidence));
    final top = kept.take(_maxDetections).toList();

    final dbService = DatabaseService();
    final results = <PredictionResult>[];

    for (final det in top) {
      final label = _labels[det.classIdx];
      final dbResult = await dbService.queryFood(label);

      // Model output is normalized to 640x640 input.
      final x1Input = (det.cx - det.w / 2) * _inputSize;
      final y1Input = (det.cy - det.h / 2) * _inputSize;
      final x2Input = (det.cx + det.w / 2) * _inputSize;
      final y2Input = (det.cy + det.h / 2) * _inputSize;

      // Undo letterbox padding, then normalize back to the original image.
      final x1 = ((x1Input - padX) / resizedW).clamp(0.0, 1.0);
      final y1 = ((y1Input - padY) / resizedH).clamp(0.0, 1.0);
      final x2 = ((x2Input - padX) / resizedW).clamp(0.0, 1.0);
      final y2 = ((y2Input - padY) / resizedH).clamp(0.0, 1.0);

      results.add(PredictionResult(
        label: label,
        confidence: det.confidence,
        ingredients: dbResult?.ingredients ?? [],
        allergens: dbResult?.allergens ?? [],
        foundInDatabase: dbResult != null,
        boundingBox: BoundingBox(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
        ),
      ));
    }

    return results;
  }

  List<_Detection> _nms(List<_Detection> detections) {
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <_Detection>[];

    for (final det in detections) {
      bool suppressed = false;
      for (final keep in kept) {
        if (keep.classIdx == det.classIdx && _iou(det, keep) > _iouThreshold) {
          suppressed = true;
          break;
        }
      }
      if (!suppressed) kept.add(det);
    }

    return kept;
  }

  double _iou(_Detection a, _Detection b) {
    final ax1 = a.cx - a.w / 2;
    final ay1 = a.cy - a.h / 2;
    final ax2 = a.cx + a.w / 2;
    final ay2 = a.cy + a.h / 2;

    final bx1 = b.cx - b.w / 2;
    final by1 = b.cy - b.h / 2;
    final bx2 = b.cx + b.w / 2;
    final by2 = b.cy + b.h / 2;

    final interX1 = max(ax1, bx1);
    final interY1 = max(ay1, by1);
    final interX2 = min(ax2, bx2);
    final interY2 = min(ay2, by2);

    final interW = max(0.0, interX2 - interX1);
    final interH = max(0.0, interY2 - interY1);
    final intersection = interW * interH;

    final union = a.w * a.h + b.w * b.h - intersection;
    return union == 0 ? 0 : intersection / union;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}

class _Detection {
  final int classIdx;
  final double confidence;
  final double cx, cy, w, h;

  _Detection({
    required this.classIdx,
    required this.confidence,
    required this.cx,
    required this.cy,
    required this.w,
    required this.h,
  });
}
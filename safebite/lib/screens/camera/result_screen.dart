import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prediction_result.dart';
import '../../providers/avoided_allergens_provider.dart';
import '../allergens/allergen_emoji.dart';

const List<Color> _kDetectionPalette = [
  Color(0xFF2979FF),
  Color(0xFFFF6D00),
  Color(0xFFD500F9),
  Color(0xFF00BCD4),
  Color(0xFFFFD600),
];

const double _kMaskLayerOpacity = 0.6;
const double _kBoxStrokeWidth = 2.5;
const double _kLabelFontSize = 9.0;

Color getDetectionColor(int index) =>
    _kDetectionPalette[index % _kDetectionPalette.length];

class ResultScreen extends StatelessWidget {
  final File image;
  final List<PredictionResult> results;
  final Uint8List? annotatedImageBytes;
  final Uint8List? maskPngBytes;

  const ResultScreen({
    super.key,
    required this.image,
    required this.results,
    this.annotatedImageBytes,
    this.maskPngBytes,
  });

  String _getFoodEmoji(List<String> allergenLabels) {
    if (allergenLabels.isEmpty) return '🍜';
    return AllergenEmoji.get(allergenLabels.first);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    final avoidedProvider = context.watch<AvoidedAllergensProvider>();

    final allDetectedAllergens =
        results.expand((r) => r.allergens).toSet().toList();

    final avoidedDetectedAllergens = allDetectedAllergens
        .where((a) => avoidedProvider.isAvoided(a))
        .toList();

    final hasResults = results.isNotEmpty;

    final hasConflict = allDetectedAllergens.any(
      (a) => avoidedProvider.isAvoided(a),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan result',
          style: TextStyle(fontSize: 16),
        ),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FutureBuilder<double>(
                    future: _getImageAspectRatio(image),
                    initialData: 1.0,
                    builder: (context, snapshot) {
                      final aspectRatio = snapshot.data ?? 1.0;

                      return AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(image, fit: BoxFit.fill),
                            if (maskPngBytes != null)
                              Opacity(
                                opacity: _kMaskLayerOpacity,
                                child: Image.memory(
                                  maskPngBytes!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            CustomPaint(
                              painter: _DetectionPainter(results: results),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (hasResults)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasConflict
                      ? const Color.fromRGBO(250, 227, 226, 1)
                      : const Color.fromRGBO(230, 250, 238, 1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasConflict
                        ? const Color.fromRGBO(240, 200, 198, 1)
                        : const Color.fromRGBO(191, 232, 207, 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasConflict
                              ? Icons.warning_amber_rounded
                              : Icons.gpp_good_outlined,
                          size: 20,
                          color: hasConflict
                              ? const Color.fromRGBO(220, 72, 56, 1)
                              : const Color.fromRGBO(82, 167, 107, 1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasConflict
                              ? 'Potential allergen'
                              : 'Looks safe for you',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: hasConflict
                                ? const Color.fromRGBO(220, 72, 56, 1)
                                : const Color.fromRGBO(82, 167, 107, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(screenWidth * 0.075, 0, 0, 0),
                      child: Text(
                        hasConflict
                            ? 'Potential allergens: ${allDetectedAllergens.join(", ")}.\nYou are avoiding: ${avoidedDetectedAllergens.join(", ")}.'
                            : allDetectedAllergens.isEmpty
                                ? 'No allergens detected.'
                                : 'Potential allergens: ${allDetectedAllergens.join(", ")}.\nNo conflict with your selected allergens.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: hasConflict
                              ? const Color.fromRGBO(213, 67, 57, 1)
                              : const Color.fromRGBO(82, 167, 107, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'IDENTIFIED ${results.length > 1 ? "DISHES" : "DISH"}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 12),
            if (results.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text(
                  "We couldn't identify the dish. Try a clearer photo or better lighting.",
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final result = results[index];
                  final color = getDetectionColor(index);

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _getFoodEmoji(result.allergens),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontFamilyFallback: [
                                      'Segoe UI Emoji',
                                      'Noto Color Emoji',
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.label,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${(result.confidence * 100).toStringAsFixed(1)}% confidence",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (result.ingredients.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              "INGREDIENTS",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.55),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              result.ingredients.join(", "),
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            "ALLERGENS",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.55),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (result.allergens.isEmpty)
                            const Text(
                              "None",
                              style: TextStyle(fontSize: 13),
                            )
                          else
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: result.allergens.map((a) {
                                final isAvoided = avoidedProvider.isAvoided(a);

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAvoided
                                        ? const Color.fromRGBO(250, 227, 226, 1)
                                        : theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AllergenEmoji.get(a),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontFamilyFallback: [
                                            'Segoe UI Emoji',
                                            'Noto Color Emoji',
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        a,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isAvoided
                                              ? const Color.fromRGBO(
                                                  213, 67, 57, 1)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<double> _getImageAspectRatio(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    final w = frame.image.width.toDouble();
    final h = frame.image.height.toDouble();

    frame.image.dispose();

    return (w > 0 && h > 0) ? w / h : 1.0;
  }
}

class _DetectionPainter extends CustomPainter {
  final List<PredictionResult> results;

  const _DetectionPainter({required this.results});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final box = result.boundingBox;

      if (box == null) continue;

      final color = getDetectionColor(i);

      final left = box.x1 * size.width;
      final top = box.y1 * size.height;
      final right = box.x2 * size.width;
      final bottom = box.y2 * size.height;

      final rect = Rect.fromLTRB(left, top, right, bottom);

      canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..strokeWidth = _kBoxStrokeWidth
          ..style = PaintingStyle.stroke,
      );

      final labelText =
          '${result.label} ${(result.confidence * 100).toStringAsFixed(1)}%';

      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: _kLabelFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.8);

      const hPad = 5.0;
      const vPad = 3.0;

      final labelW = textPainter.width + hPad * 2;
      final labelH = textPainter.height + vPad * 2;

      double labelTop = top - labelH;
      if (labelTop < 0) labelTop = top;

      double labelLeft = left;
      if (labelLeft + labelW > size.width) {
        labelLeft = size.width - labelW;
      }
      if (labelLeft < 0) labelLeft = 0;

      final labelRect = Rect.fromLTWH(
        labelLeft,
        labelTop,
        labelW,
        labelH,
      );

      canvas.drawRect(
        labelRect,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );

      textPainter.paint(
        canvas,
        Offset(labelLeft + hPad, labelTop + vPad),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter oldDelegate) {
    return oldDelegate.results != results;
  }
}

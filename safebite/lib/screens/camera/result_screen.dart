import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/prediction_result.dart';
import '../allergens/allergen_emoji.dart';

Color getDetectionColor(int index) {
  const palette = [
    Color(0xFF4E9AF1),
    Color(0xFF9D5CE0),
    Color(0xFFE0B05C),
    Color(0xFF5C7CE0),
    Color(0xFFE05CB8),
    Color(0xFF5CC2E0),
    Color(0xFFC0A05C),
  ];

  return palette[index % palette.length];
}

class ResultScreen extends StatelessWidget {
  final File image;
  final List<PredictionResult> results;

  const ResultScreen({
    super.key,
    required this.image,
    required this.results,
  });

  String _getFoodEmoji(List<String> allergenLabels) {
    if (allergenLabels.isEmpty) return '🍜';
    return AllergenEmoji.get(allergenLabels.first);
  }

  Future<ui.Image> _loadUiImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final allTriggered = results.expand((r) => r.allergens).toSet().toList();
    final hasResults = results.isNotEmpty;
    final hasAlert = hasResults && allTriggered.isNotEmpty;

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
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 520,
                  minHeight: 220,
                ),
                child: FutureBuilder<ui.Image>(
                  future: _loadUiImage(image),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.black12,
                      );
                    }

                    final imageWidth = snapshot.data!.width.toDouble();
                    final imageHeight = snapshot.data!.height.toDouble();
                    final aspectRatio = imageWidth / imageHeight;

                    return AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            image,
                            fit: BoxFit.contain,
                          ),
                          CustomPaint(
                            painter: _DetectionPainter(
                              results: results,
                              imageWidth: imageWidth,
                              imageHeight: imageHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (hasResults)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasAlert
                      ? const Color.fromRGBO(250, 227, 226, 1)
                      : const Color.fromRGBO(230, 250, 238, 1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasAlert
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
                          hasAlert
                              ? Icons.warning_amber_rounded
                              : Icons.gpp_good_outlined,
                          size: 20,
                          color: hasAlert
                              ? const Color.fromRGBO(220, 72, 56, 1)
                              : const Color.fromRGBO(82, 167, 107, 1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasAlert ? 'Allergen detected' : 'Looks safe for you',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: hasAlert
                                ? const Color.fromRGBO(220, 72, 56, 1)
                                : const Color.fromRGBO(82, 167, 107, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasAlert
                          ? 'Identified dish contains: ${allTriggered.join(", ")}.'
                          : 'No conflicts with your selected allergens.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: hasAlert
                            ? const Color.fromRGBO(213, 67, 57, 1)
                            : const Color.fromRGBO(82, 167, 107, 1),
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withOpacity(0.4), // colored border
                        width: 1.2,
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
                                      "${(result.confidence * 100).toStringAsFixed(1)}% match",
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
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
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
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
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
}

class _DetectionPainter extends CustomPainter {
  final List<PredictionResult> results;
  final double imageWidth;
  final double imageHeight;
  final BoxFit fit;

  _DetectionPainter({
    required this.results,
    required this.imageWidth,
    required this.imageHeight,
    required this.fit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> palette = [
      const Color(0xFF4E9AF1),
      const Color(0xFF9D5CE0),
      const Color(0xFFE0B05C),
      const Color(0xFF5C7CE0),
      const Color(0xFFE05CB8),
      const Color(0xFF5CC2E0),
      const Color(0xFFC0A05C),
    ];

    final fitted = applyBoxFit(
      fit,
      Size(imageWidth, imageHeight),
      size,
    );

    final src = Alignment.center.inscribe(
      fitted.source,
      Offset.zero & Size(imageWidth, imageHeight),
    );

    final dst = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );

    final scaleX = dst.width / src.width;
    final scaleY = dst.height / src.height;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final box = result.boundingBox;
      if (box == null) continue;

      final color = palette[i % palette.length];

      final boxPaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      // final fillPaint = Paint()
      //   ..color = color.withOpacity(0.12)
      //   ..style = PaintingStyle.fill;

      final labelBgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final left = dst.left + ((box.x1 * imageWidth) - src.left) * scaleX;
      final top = dst.top + ((box.y1 * imageHeight) - src.top) * scaleY;
      final right = dst.left + ((box.x2 * imageWidth) - src.left) * scaleX;
      final bottom = dst.top + ((box.y2 * imageHeight) - src.top) * scaleY;

      final rect = Rect.fromLTRB(left, top, right, bottom);

      // canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, boxPaint);

      final labelText =
          '${result.label} ${(result.confidence * 100).toStringAsFixed(1)}%';

      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.8);

      const padding = 6.0;
      final labelHeight = textPainter.height + 6;

      double labelTop = top - labelHeight;
      if (labelTop < 0) labelTop = top;

      final labelRect = Rect.fromLTWH(
        left,
        labelTop,
        textPainter.width + padding * 2,
        labelHeight,
      );

      canvas.drawRect(labelRect, labelBgPaint);
      textPainter.paint(canvas, Offset(left + padding, labelTop + 3));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter oldDelegate) {
    return oldDelegate.results != results ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.fit != fit;
  }
}

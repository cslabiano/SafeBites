import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/prediction_result.dart';
import '../../services/food_detector_service.dart';
import '../allergens/allergen_emoji.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Fallback painter — used when annotatedImageBytes is null
// ─────────────────────────────────────────────────────────────────────────────

class _DetectionPainter extends CustomPainter {
  final List<PredictionResult> results;

  _DetectionPainter({required this.results});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < results.length; i++) {
      _draw(canvas, size, results[i], FoodDetectorService.colorForClass(i));
    }
  }

  void _draw(
      Canvas canvas, Size size, PredictionResult r, ui.Color color) {
    // ── Mask ────────────────────────────────────────────────────────────
    if (r.maskPoints.length >= 3) {
      final fill = Paint()
        ..color = color.withOpacity(0.28)
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = color.withOpacity(0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final path = Path()
        ..moveTo(r.maskPoints[0].dx * size.width,
            r.maskPoints[0].dy * size.height);
      for (int i = 1; i < r.maskPoints.length; i++) {
        path.lineTo(
            r.maskPoints[i].dx * size.width, r.maskPoints[i].dy * size.height);
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }

    // ── Bounding box ────────────────────────────────────────────────────
    final bbox = r.boundingBox;
    if (bbox == null) return;

    final rect = Rect.fromLTRB(
      bbox.x1 * size.width,
      bbox.y1 * size.height,
      bbox.x2 * size.width,
      bbox.y2 * size.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // ── Label badge ─────────────────────────────────────────────────────
    final text =
        '${r.label}  ${(r.confidence * 100).toStringAsFixed(0)}%';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const hPad = 7.0, vPad = 4.0;
    final bw = tp.width + hPad * 2;
    final bh = tp.height + vPad * 2;
    double bl = rect.left;
    double bt = rect.top - bh - 2;
    if (bt < 0) bt = rect.top + 2;
    if (bl + bw > size.width) bl = size.width - bw - 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bl, bt, bw, bh),
        const Radius.circular(4),
      ),
      Paint()..color = color,
    );
    tp.paint(canvas, Offset(bl + hPad, bt + vPad));
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Result screen
// ─────────────────────────────────────────────────────────────────────────────

class ResultScreen extends StatefulWidget {
  final File image;
  final List<PredictionResult> results;

  /// Pre-rendered image with boxes + masks drawn natively by ultralytics_yolo.
  /// When non-null, this is shown instead of the raw image + painter overlay.
  final Uint8List? annotatedImageBytes;

  const ResultScreen({
    super.key,
    required this.image,
    required this.results,
    this.annotatedImageBytes,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  /// Only needed for the fallback painter path (no annotatedImageBytes).
  ui.Image? _uiImage;

  @override
  void initState() {
    super.initState();
    // Only decode the raw image if we have no native annotated version.
    if (widget.annotatedImageBytes == null) _loadRawImage();
  }

  Future<void> _loadRawImage() async {
    final bytes = await widget.image.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) setState(() => _uiImage = frame.image);
  }

  String _getFoodEmoji(List<String> allergens) {
    if (allergens.isEmpty) return '🍜';
    return AllergenEmoji.get(allergens.first);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTriggered =
        widget.results.expand((r) => r.allergens).toSet().toList();
    final hasResults = widget.results.isNotEmpty;
    final hasAlert = hasResults && allTriggered.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan result', style: TextStyle(fontSize: 16)),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with detection overlay ────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // If the plugin returned a pre-annotated image, use it
                    // directly (boxes + masks already drawn natively).
                    if (widget.annotatedImageBytes != null)
                      Image.memory(
                        widget.annotatedImageBytes!,
                        fit: BoxFit.cover,
                      )
                    else ...[
                      // Fallback: raw image + Dart-side painter overlay
                      Image.file(widget.image, fit: BoxFit.cover),
                      if (_uiImage != null && widget.results.isNotEmpty)
                        CustomPaint(
                          painter:
                              _DetectionPainter(results: widget.results),
                        ),
                      if (_uiImage == null && widget.results.isNotEmpty)
                        const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Alert banner ────────────────────────────────────────────
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
                          hasAlert
                              ? 'Allergen detected'
                              : 'Looks safe for you',
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
              'IDENTIFIED ${widget.results.length > 1 ? "DISHES" : "DISH"}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 12),

            // ── Detection cards ─────────────────────────────────────────
            if (widget.results.isEmpty)
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
                itemCount: widget.results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final result = widget.results[index];
                  final dotColor = FoodDetectorService.colorForClass(index);

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Colour dot matches the overlay colour
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: dotColor.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: dotColor.withOpacity(0.6),
                                    width: 2,
                                  ),
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
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.55),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (result.allergens.isEmpty)
                            const Text("None",
                                style: TextStyle(fontSize: 13))
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
                                        color: Colors.grey.shade300),
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
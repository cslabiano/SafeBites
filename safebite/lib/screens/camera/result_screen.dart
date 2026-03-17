import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/prediction_result.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final PredictionResult result;

  const ResultScreen({
    super.key,
    required this.image,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📷 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(image,
                  height: 200, width: double.infinity, fit: BoxFit.cover),
            ),

            const SizedBox(height: 16),

            // 🍔 Label
            Text(
              result.label,
              style: theme.textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            // 📊 Confidence
            Text(
              "Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%",
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // ⚠️ Allergens
            Text(
              "Detected Allergens",
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: result.allergens.map((a) {
                return Chip(
                  label: Text(a),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

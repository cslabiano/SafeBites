import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/prediction_result.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final List<PredictionResult> results;

  const ResultScreen({
    super.key,
    required this.image,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final allAllergens =
        results.expand((result) => result.allergens).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Single pop — only dismisses the ResultScreen itself.
          // The Camera screen remains in the stack so the user can scan again.
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Captured / selected image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            Text("Detected Foods", style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              "${results.length} item${results.length == 1 ? '' : 's'} detected",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // ── All allergens summary ──────────────────────────────────────
            Text("Detected Allergens", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (allAllergens.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("No allergens detected."),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allAllergens.map((allergen) {
                  return Chip(
                    label: Text(allergen),
                    backgroundColor: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // ── Per-food cards ─────────────────────────────────────────────
            if (results.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "No food was confidently detected in the image.",
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

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%",
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          result.foundInDatabase
                              ? "Found in local database"
                              : "Detected by model only (not matched in local database)",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),

                        // Ingredients
                        Text(
                          "Ingredients",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (result.ingredients.isEmpty)
                          const Text("No ingredient data available.")
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: result.ingredients.map((ingredient) {
                              return Chip(
                                label: Text(ingredient),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide.none,
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 12),

                        // Allergens
                        Text(
                          "Allergens",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (result.allergens.isEmpty)
                          const Text("None")
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: result.allergens.map((a) {
                              return Chip(
                                label: Text(a),
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide.none,
                              );
                            }).toList(),
                          ),
                      ],
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

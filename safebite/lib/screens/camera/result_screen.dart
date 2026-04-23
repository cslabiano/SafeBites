import 'dart:io';
import 'package:flutter/material.dart';

import '../../models/prediction_result.dart';
import '../allergens/allergen_emoji.dart';

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
              child: Image.file(
                image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
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

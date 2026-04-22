import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/avoided_allergens_provider.dart';
import '../allergens/allergen_emoji.dart';

class FoodDetailsPage extends StatelessWidget {
  final String title;
  final String ingredients;
  final String? sourceLink;
  final List<String> allergenLabels;

  const FoodDetailsPage({
    super.key,
    required this.title,
    required this.ingredients,
    this.sourceLink,
    this.allergenLabels = const [],
  });

  List<String> _buildIngredientList() {
    return ingredients
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avoided = context.watch<AvoidedAllergensProvider>().avoided;
    final ingredientList = _buildIngredientList();

    final triggeredAllergens =
        allergenLabels.where((a) => avoided.contains(a)).toList();
    final hasAlert = triggeredAllergens.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Food details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasAlert
                      ? const Color.fromRGBO(245, 233, 231, 1)
                      : const Color.fromRGBO(232, 244, 237, 1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasAlert
                        ? const Color.fromRGBO(236, 184, 180, 1)
                        : const Color.fromRGBO(192, 222, 196, 1),
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
                              ? const Color.fromRGBO(213, 67, 57, 1)
                              : const Color.fromRGBO(82, 167, 107, 1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasAlert ? 'Allergen alert' : 'Safe for you',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: hasAlert
                                ? const Color.fromRGBO(213, 67, 57, 1)
                                : const Color.fromRGBO(82, 167, 107, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasAlert
                          ? 'This dish contains ${triggeredAllergens.map((a) => a.toLowerCase()).join(', ')} (on your avoid list).'
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
                'INGREDIENTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: ingredientList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No ingredients available.',
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    : Column(
                        children: List.generate(ingredientList.length, (index) {
                          final ingredient = ingredientList[index];
                          final isLast = index == ingredientList.length - 1;

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                            ),
                            child: Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          );
                        }),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                'CONTAINS ALLERGENS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 10),
              if (allergenLabels.isEmpty)
                Text(
                  'No common allergens detected.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allergenLabels.map((allergen) {
                    final isAvoided = avoided.contains(allergen);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:  Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AllergenEmoji.get(allergen),
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamilyFallback: [
                                'Segoe UI Emoji',
                                'Noto Color Emoji',
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            allergen,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:  theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              if (sourceLink != null && sourceLink!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'SOURCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: SelectableText(
                    sourceLink!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../database/food_repository.dart';
import '../../widgets/food_card.dart';
import '../allergens/allergen_emoji.dart';
import 'food_details.dart';

class FeaturedSection extends StatelessWidget {
  final List<Map<String, dynamic>> foods;
  final FoodRepository repo;
  final List<Map<String, dynamic>> allergens;
  final List<String> selectedExcludedAllergens;
  final bool isLoading;
  final Future<void> Function(String allergen) onToggleAllergen;

  const FeaturedSection({
    super.key,
    required this.foods,
    required this.repo,
    required this.allergens,
    required this.selectedExcludedAllergens,
    required this.isLoading,
    required this.onToggleAllergen,
  });

  static const List<String> _allergenOrder = [
    'Milk',
    'Egg',
    'Tree Nut',
    'Soy',
    'Fish',
    'Sesame',
    'Peanut',
    'Wheat',
    'Shellfish',
  ];

  List<String> _extractAllergens(Map<String, dynamic> food) {
    final raw = food['allergens'];

    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (raw is String) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ Sort allergens for display
    final sortedAllergens = List<Map<String, dynamic>>.from(allergens)
      ..sort((a, b) {
        final aName = a['name']?.toString() ?? '';
        final bName = b['name']?.toString() ?? '';

        final aIndex = _allergenOrder.indexOf(aName);
        final bIndex = _allergenOrder.indexOf(bName);

        if (aIndex == -1 && bIndex == -1) return 0;
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;

        return aIndex.compareTo(bIndex);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.gpp_maybe_outlined,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'AVOID THESE ALLERGENS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: theme.colorScheme.onSurface.withOpacity(0.65),
                ),
              ),
            ),
            Text(
              '${selectedExcludedAllergens.length} active',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: sortedAllergens.map((allergen) {
              final allergenName = allergen['name']?.toString() ?? '';
              final isSelected =
                  selectedExcludedAllergens.contains(allergenName);

              return InkWell(
                onTap: () => onToggleAllergen(allergenName),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(220, 72, 56, 1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? const Color.fromRGBO(220, 72, 56, 1)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AllergenEmoji.get(allergenName),
                        style: const TextStyle(
                          fontSize: 9,
                          fontFamilyFallback: [
                            'Segoe UI Emoji',
                            'Noto Color Emoji',
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        allergenName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(
              Icons.thumb_up_alt_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              "Today's Featured Foods",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (foods.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              'No featured foods match the selected allergen filters.',
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: foods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final food = foods[index];
              final allergenLabels = _extractAllergens(food);
              final triggeredAllergens = allergenLabels
                  .where((a) => selectedExcludedAllergens.contains(a))
                  .toList();

              return FoodCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailsPage(
                        title: food['name'] ?? '',
                        ingredients: food['ingredients'] ?? '',
                        sourceLink: food['source_link']?.toString(),
                        allergenLabels: allergenLabels,
                      ),
                    ),
                  );
                },
                title: food['name'] ?? '',
                ingredients: food['ingredients'] ?? 'N/A',
                hasAlert: triggeredAllergens.isNotEmpty,
                allergenLabels: allergenLabels,
                triggeredAllergens: triggeredAllergens,
              );
            },
          ),
      ],
    );
  }
}

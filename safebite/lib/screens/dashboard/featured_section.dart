import 'package:flutter/material.dart';

import '../../widgets/food_card.dart';
import '../../database/food_repository.dart';
import 'food_details.dart';

class FeaturedSection extends StatelessWidget {
  final List<Map<String, dynamic>> foods;
  final FoodRepository repo;
  final List<Map<String, dynamic>> allergens;
  final List<String> selectedExcludedAllergens;
  final bool isLoading;
  final VoidCallback onOpenFilter;
  final Future<void> Function(String allergen) onRemoveAllergen;

  const FeaturedSection({
    super.key,
    required this.foods,
    required this.repo,
    required this.allergens,
    required this.selectedExcludedAllergens,
    required this.isLoading,
    required this.onOpenFilter,
    required this.onRemoveAllergen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Featured Foods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: allergens.isEmpty ? null : onOpenFilter,
              icon: const Icon(Icons.filter_alt_outlined, size: 16),
              label: const Text('Filter'),
            ),
          ],
        ),
        if (selectedExcludedAllergens.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedExcludedAllergens.map((allergen) {
              return Chip(
                label: Text(allergen),
                onDeleted: () => onRemoveAllergen(allergen),
                deleteIconColor: const Color.fromRGBO(145, 31, 27, 1),
                backgroundColor: const Color.fromRGBO(250, 227, 226, 1),
                labelStyle: const TextStyle(
                  color: Color.fromRGBO(145, 31, 27, 1),
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 10),
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
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No featured foods match the selected allergen filters.',
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: foods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final food = foods[index];

              return FoodCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailsPage(
                        title: food['name'],
                        ingredients: food['ingredients'] ?? '',
                        sourceLink: food['source_link']?.toString(),
                      ),
                    ),
                  );
                },
                iconData: Icons.restaurant_outlined,
                title: food['name'],
                ingredients: food['ingredients'] ?? 'N/A',
              );
            },
          ),
      ],
    );
  }
}

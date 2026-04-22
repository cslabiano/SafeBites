import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/food_repository.dart';
import '../../providers/avoided_allergens_provider.dart';
import '../../widgets/food_card.dart';
import 'food_details.dart';

class SearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> foods;
  final FoodRepository repo;

  const SearchResults({
    super.key,
    required this.foods,
    required this.repo,
  });

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
    final avoided = context.watch<AvoidedAllergensProvider>().avoided;
    final theme = Theme.of(context);

    if (foods.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text('No foods found.'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: foods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final food = foods[index];
        final allergenLabels = _extractAllergens(food);
        final triggeredAllergens =
            allergenLabels.where((a) => avoided.contains(a)).toList();

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
          title: food['name'] ?? 'Unknown food',
          ingredients: food['ingredients'] ?? 'No ingredients available',
          hasAlert: triggeredAllergens.isNotEmpty,
          allergenLabels: allergenLabels,
          triggeredAllergens: triggeredAllergens,
        );
      },
    );
  }
}

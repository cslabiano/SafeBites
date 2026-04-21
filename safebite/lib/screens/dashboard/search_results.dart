import 'package:flutter/material.dart';

import '../../database/food_repository.dart';
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

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No foods found.'),
      );
    }

    return ListView.separated(
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
          iconData: Icons.fastfood_outlined,
          title: food['name'] ?? 'Unknown food',
          ingredients: food['ingredients'] ?? 'No ingredients available',
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../widgets/food_card.dart';
import '../../../database/food_repository.dart';
import '../food_details.dart';

class DailyFoodSection extends StatelessWidget {
  final List foods;
  final FoodRepository repo;

  const DailyFoodSection({
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
        child: const Text(
          'No featured foods match the selected allergen filters.',
        ),
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
                  title: food["name"],
                  ingredients: food["ingredients"] ?? "",
                  sourceLink: food["source_link"]?.toString(),
                ),
              ),
            );
          },
          title: food["name"],
          ingredients: food["ingredients"] ?? "N/A",
        );
      },
    );
  }
}

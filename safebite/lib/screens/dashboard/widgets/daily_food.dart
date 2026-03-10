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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        var food = foods[index];

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
          ingredients: food["ingredients"] ?? "N/As",
        );
      },
    );
  }
}

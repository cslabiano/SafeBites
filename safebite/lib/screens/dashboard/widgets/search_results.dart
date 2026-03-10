import 'package:flutter/material.dart';
import '../../../widgets/food_card.dart';
import '../../../database/food_repository.dart';
import '../food_details.dart';

class SearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> foods;
  final FoodRepository repo;

  const SearchResults({
    super.key,
    required this.foods,
    required this.repo,
  });

  String formatIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.map((ingredient) {
      final name = ingredient["name"]?.toString() ?? "";

      if (ingredient["is_optional"] == 1) {
        return "$name (optional)";
      }

      return name;
    }).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    /// EMPTY RESULTS
    if (foods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(
          child: Text(
            "No foods found",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foods.length,
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

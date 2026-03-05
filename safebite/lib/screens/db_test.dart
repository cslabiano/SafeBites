import 'package:flutter/material.dart';
import '../database/food_repository.dart';

class DBTestScreen extends StatefulWidget {
  const DBTestScreen({super.key});

  @override
  State<DBTestScreen> createState() => _DBTestScreenState();
}

class _DBTestScreenState extends State<DBTestScreen> {
  final FoodRepository repo = FoodRepository();

  List foods = [];
  List ingredients = [];

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    var result = await repo.getFoods();

    setState(() {
      foods = result;
    });
  }

  Future<void> loadIngredients(int foodId) async {
    var result = await repo.getIngredients(foodId);

    setState(() {
      ingredients = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Database Test")),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text("Foods"),
          Expanded(
            child: ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                var food = foods[index];

                return ListTile(
                  title: Text(food.name),
                  onTap: () {
                    print("Selected food id: ${food.id}");
                    loadIngredients(food.id);
                  },
                );
              },
            ),
          ),
          const Divider(),
          const Text("Ingredients"),
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                var item = ingredients[index];

                String name = item["name"];
                int optional = item["is_optional"];

                if (optional == 1) {
                  name = "$name (Optional)";
                }

                return Text(name);
              },
            ),
          ),
        ],
      ),
    );
  }
}

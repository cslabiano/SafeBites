import 'dart:math';

import '../../database/food_repository.dart';

class DashboardController {
  final FoodRepository repo = FoodRepository();

  Future<List<Map<String, dynamic>>> loadAllergens() async {
    return await repo.getAllergens();
  }

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    return await repo.searchFoods(query);
  }

  Future<List<Map<String, dynamic>>> loadFeaturedFoods({
    List<String> excludedAllergens = const [],
  }) async {
    final safeFoods = await repo.getSafeFoods(excludedAllergens);

    if (safeFoods.isEmpty) return [];

    final today = DateTime.now();
    final daySeed =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

    final shuffledFoods = List<Map<String, dynamic>>.from(safeFoods)
      ..shuffle(Random(daySeed));

    return shuffledFoods.take(3).toList();
  }
}

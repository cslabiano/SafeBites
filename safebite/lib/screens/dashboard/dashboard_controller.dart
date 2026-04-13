import 'dart:math';
import '../../database/food_repository.dart';

class DashboardController {
  final FoodRepository repo = FoodRepository();

  Future<List<Map<String, dynamic>>> loadAllergens() async {
    final result = await repo.getAllergens();
    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> loadFeaturedFoods({
    List<String> excludedAllergens = const [],
  }) async {
    final result = excludedAllergens.isEmpty
        ? await repo.getFoods()
        : await repo.getSafeFoods(excludedAllergens);

    if (result.isEmpty) return [];

    final foods = List<Map<String, dynamic>>.from(result);

    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;

    foods.shuffle(Random(seed));

    return foods.take(min(3, foods.length)).toList();
  }

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    if (query.trim().isEmpty) return [];

    final result = await repo.searchFoods(query.trim());
    return List<Map<String, dynamic>>.from(result);
  }
}

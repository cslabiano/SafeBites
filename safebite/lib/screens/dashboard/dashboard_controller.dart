import 'dart:math';
import '../../database/food_repository.dart';

class DashboardController {
  final FoodRepository repo = FoodRepository();

  Future<List> loadAllergens() async {
    return await repo.getAllergens();
  }

  Future<List<Map<String, dynamic>>> loadDailyFoods(
      List<String> allergies) async {
    final result = await repo.getSafeFoods(allergies);

    if (result.isEmpty) return [];

    final foods = List<Map<String, dynamic>>.from(result);

    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;

    foods.shuffle(Random(seed));

    return foods.take(min(3, foods.length)).toList();
  }

  Future<List> searchFoods(String query) async {
    if (query.isEmpty) return [];
    return await repo.searchFoods(query);
  }
}

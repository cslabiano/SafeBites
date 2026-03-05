import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/food.dart';

class FoodRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// GET ALL FOODS
  Future<List<Food>> getFoods() async {
    final db = await _databaseHelper.database;

    final result = await db.query("foods");

    return result.map((e) => Food.fromMap(e)).toList();
  }

  /// GET FOOD BY NAME (for YOLO detection)
  Future<Map<String, dynamic>?> getFoodByName(String name) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      "foods",
      where: "name = ?",
      whereArgs: [name],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  /// GET INGREDIENTS OF FOOD
  Future<List<Map<String, dynamic>>> getIngredients(int foodId) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
    SELECT ingredients.name, food_ingredients.is_optional
    FROM ingredients
    JOIN food_ingredients
    ON ingredients.id = food_ingredients.ingredient_id
    WHERE food_ingredients.food_id = ?
  ''', [foodId]);

    print("INGREDIENT RESULT: $result");

    return result;
  }

  /// GET ALLERGENS IN A FOOD
  Future<List<String>> getFoodAllergens(int foodId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT allergens.name
      FROM allergens
      JOIN ingredient_allergens
      ON allergens.id = ingredient_allergens.allergen_id
      JOIN food_ingredients
      ON ingredient_allergens.ingredient_id = food_ingredients.ingredient_id
      WHERE food_ingredients.food_id = ?
    ''', [foodId]);

    return result.map((e) => e["name"].toString()).toList();
  }

  /// GET ALLERGEN INFO
  Future<Map<String, dynamic>?> getAllergenInfo(String allergen) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      "allergens",
      where: "name = ?",
      whereArgs: [allergen],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // GET ALLERGENS
  Future<List<Map<String, dynamic>>> getAllergens() async {
    final db = await _databaseHelper.database;
    final result = await db.query("allergens");
    return result;
  }

  // GET USER ALLERGIES
  Future<List<String>> getUserAllergies() async {
    final db = await _databaseHelper.database;
    final result = await db.query("user_allergies");
    return result.map((e) => e["allergen_id"].toString()).toList();
  }
}

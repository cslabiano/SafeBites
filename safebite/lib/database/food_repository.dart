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

  /// GET INGREDIENTS OF FOOD (used for detailed views)
  Future<List<Map<String, dynamic>>> getIngredients(int foodId) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT ingredients.name, food_ingredients.is_optional
      FROM ingredients
      JOIN food_ingredients
        ON ingredients.id = food_ingredients.ingredient_id
      WHERE food_ingredients.food_id = ?
      AND ingredients.name IS NOT NULL
      AND TRIM(ingredients.name) != ''
    ''', [foodId]);

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

  /// GET ALL ALLERGENS (used for allergen selection UI)
  Future<List<Map<String, dynamic>>> getAllergens() async {
    final db = await _databaseHelper.database;

    final result = await db.query("allergens");

    return result;
  }

  /// SEARCH FOODS
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        foods.id,
        foods.name,
        foods.source_link,
        GROUP_CONCAT(
          CASE
            WHEN ingredients.name IS NULL THEN NULL
            WHEN food_ingredients.is_optional = 1
              THEN ingredients.name || ' (optional)'
            ELSE ingredients.name
          END,
          ', '
        ) AS ingredients
      FROM foods
      LEFT JOIN food_ingredients
        ON foods.id = food_ingredients.food_id
      LEFT JOIN ingredients
        ON ingredients.id = food_ingredients.ingredient_id
      WHERE foods.name LIKE ?
      GROUP BY foods.id
    ''', ['%$query%']);

    return result;
  }

  /// GET SAFE FOODS BASED ON USER ALLERGIES
  Future<List<Map<String, dynamic>>> getSafeFoods(
      List<String> allergies) async {
    final db = await _databaseHelper.database;

    /// If user has no allergies → return all foods
    if (allergies.isEmpty) {
      return await db.rawQuery('''
        SELECT 
          foods.id,
          foods.name,
          foods.source_link,
          GROUP_CONCAT(
            CASE
              WHEN ingredients.name IS NULL THEN NULL
              WHEN food_ingredients.is_optional = 1
                THEN ingredients.name || ' (optional)'
              ELSE ingredients.name
            END,
            ', '
          ) AS ingredients
        FROM foods
        LEFT JOIN food_ingredients
          ON foods.id = food_ingredients.food_id
        LEFT JOIN ingredients
          ON ingredients.id = food_ingredients.ingredient_id
        GROUP BY foods.id
      ''');
    }

    final placeholders = List.filled(allergies.length, '?').join(',');

    final result = await db.rawQuery('''
      SELECT 
        foods.id,
        foods.name,
        foods.source_link,
        GROUP_CONCAT(
          CASE
            WHEN ingredients.name IS NULL THEN NULL
            WHEN food_ingredients.is_optional = 1
              THEN ingredients.name || ' (optional)'
            ELSE ingredients.name
          END,
          ', '
        ) AS ingredients
      FROM foods
      LEFT JOIN food_ingredients
        ON foods.id = food_ingredients.food_id
      LEFT JOIN ingredients
        ON ingredients.id = food_ingredients.ingredient_id
      WHERE foods.id NOT IN (
        SELECT food_ingredients.food_id
        FROM food_ingredients
        JOIN ingredient_allergens
          ON food_ingredients.ingredient_id = ingredient_allergens.ingredient_id
        JOIN allergens
          ON allergens.id = ingredient_allergens.allergen_id
        WHERE allergens.name IN ($placeholders)
      )
      GROUP BY foods.id
    ''', allergies);

    return result;
  }
}

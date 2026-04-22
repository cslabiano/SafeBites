import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/food.dart';
import '../models/prediction_result.dart';

class FoodRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Food>> getFoods() async {
    final db = await _databaseHelper.database;
    final result = await db.query("foods");
    return result.map((e) => Food.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>?> getFoodByName(String name) async {
    final db = await _databaseHelper.database;

    final normalized = name.trim().toLowerCase();

    final result = await db.query(
      "foods",
      where: "LOWER(TRIM(name)) = ?",
      whereArgs: [normalized],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

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

  Future<List<Map<String, dynamic>>> getAllergens() async {
    final db = await _databaseHelper.database;
    return await db.query("allergens");
  }

  Future<List<Map<String, dynamic>>> getFoodsByAllergen(
      String allergenName) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
    SELECT 
      foods.id,
      foods.name,
      foods.source_link,
      GROUP_CONCAT(
        DISTINCT CASE
          WHEN ingredients.name IS NULL THEN NULL
          WHEN food_ingredients.is_optional = 1
            THEN ingredients.name || ' (optional)'
          ELSE ingredients.name
        END
      ) AS ingredients,
      GROUP_CONCAT(
        DISTINCT allergens_all.name
      ) AS allergens
    FROM foods
    JOIN food_ingredients
      ON foods.id = food_ingredients.food_id
    JOIN ingredient_allergens target_ia
      ON food_ingredients.ingredient_id = target_ia.ingredient_id
    JOIN allergens target_allergen
      ON target_allergen.id = target_ia.allergen_id
    LEFT JOIN ingredients
      ON ingredients.id = food_ingredients.ingredient_id
    LEFT JOIN ingredient_allergens ia_all
      ON ingredients.id = ia_all.ingredient_id
    LEFT JOIN allergens allergens_all
      ON allergens_all.id = ia_all.allergen_id
    WHERE target_allergen.name = ?
    GROUP BY foods.id
  ''', [allergenName]);

    return result;
  }

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
    SELECT 
      foods.id,
      foods.name,
      foods.source_link,
      GROUP_CONCAT(
        DISTINCT CASE
          WHEN ingredients.name IS NULL THEN NULL
          WHEN food_ingredients.is_optional = 1
            THEN ingredients.name || ' (optional)'
          ELSE ingredients.name
        END
      ) AS ingredients,
      GROUP_CONCAT(
        DISTINCT allergens.name
      ) AS allergens
    FROM foods
    LEFT JOIN food_ingredients
      ON foods.id = food_ingredients.food_id
    LEFT JOIN ingredients
      ON ingredients.id = food_ingredients.ingredient_id
    LEFT JOIN ingredient_allergens
      ON ingredients.id = ingredient_allergens.ingredient_id
    LEFT JOIN allergens
      ON allergens.id = ingredient_allergens.allergen_id
    WHERE foods.name LIKE ?
    GROUP BY foods.id
  ''', ['%$query%']);

    return result;
  }

  Future<List<Map<String, dynamic>>> getSafeFoods(
      List<String> allergies) async {
    final db = await _databaseHelper.database;

    if (allergies.isEmpty) {
      return await db.rawQuery('''
      SELECT 
        foods.id,
        foods.name,
        foods.source_link,
        GROUP_CONCAT(
          DISTINCT CASE
            WHEN ingredients.name IS NULL THEN NULL
            WHEN food_ingredients.is_optional = 1
              THEN ingredients.name || ' (optional)'
            ELSE ingredients.name
          END
        ) AS ingredients,
        GROUP_CONCAT(
          DISTINCT allergens.name
        ) AS allergens
      FROM foods
      LEFT JOIN food_ingredients
        ON foods.id = food_ingredients.food_id
      LEFT JOIN ingredients
        ON ingredients.id = food_ingredients.ingredient_id
      LEFT JOIN ingredient_allergens
        ON ingredients.id = ingredient_allergens.ingredient_id
      LEFT JOIN allergens
        ON allergens.id = ingredient_allergens.allergen_id
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
        DISTINCT CASE
          WHEN ingredients.name IS NULL THEN NULL
          WHEN food_ingredients.is_optional = 1
            THEN ingredients.name || ' (optional)'
          ELSE ingredients.name
        END
      ) AS ingredients,
      GROUP_CONCAT(
        DISTINCT allergens.name
      ) AS allergens
    FROM foods
    LEFT JOIN food_ingredients
      ON foods.id = food_ingredients.food_id
    LEFT JOIN ingredients
      ON ingredients.id = food_ingredients.ingredient_id
    LEFT JOIN ingredient_allergens
      ON ingredients.id = ingredient_allergens.ingredient_id
    LEFT JOIN allergens
      ON allergens.id = ingredient_allergens.allergen_id
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

  Future<PredictionResult> enrichPrediction(PredictionResult prediction) async {
    final food = await getFoodByName(prediction.label);

    if (food == null) {
      return prediction.copyWith(
        foundInDatabase: false,
        allergens: const [],
        ingredients: const [],
      );
    }

    final int foodId = food['id'] as int;
    final allergens = await getFoodAllergens(foodId);
    final ingredientsRaw = await getIngredients(foodId);

    final ingredients = ingredientsRaw
        .map((row) {
          final name = (row['name'] ?? '').toString().trim();
          final isOptional = row['is_optional'] == 1;
          return isOptional ? '$name (optional)' : name;
        })
        .where((e) => e.isNotEmpty)
        .toList();

    return prediction.copyWith(
      label: (food['name'] ?? prediction.label).toString(),
      allergens: allergens,
      ingredients: ingredients,
      sourceLink: food['source_link']?.toString(),
      foundInDatabase: true,
    );
  }
}

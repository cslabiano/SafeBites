import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class FoodDbResult {
  final List<String> ingredients;
  final List<String> allergens;

  FoodDbResult({required this.ingredients, required this.allergens});
}

class DatabaseService {
  static Database? _db;
  static const _dbName = 'safebite.db';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);

    // Copy the bundled DB to writable storage on first run.
    // pubspec.yaml declares: assets/database/safebite.db
    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/database/$_dbName');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(dbPath, readOnly: true);
  }

  /// Returns null if food is not found in the database.
  Future<FoodDbResult?> queryFood(String foodName) async {
    final db = await database;

    // Case-insensitive match against the foods table
    final foodRows = await db.query(
      'foods',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [foodName],
      limit: 1,
    );

    if (foodRows.isEmpty) return null;

    final foodId = foodRows.first['id'] as int;

    // Fetch ingredients
    final ingredientRows = await db.rawQuery('''
      SELECT i.name
      FROM ingredients i
      JOIN food_ingredients fi ON fi.ingredient_id = i.id
      WHERE fi.food_id = ?
      ORDER BY i.name
    ''', [foodId]);

    final ingredients = ingredientRows.map((r) => r['name'] as String).toList();

    // Fetch allergens via ingredient_allergens
    final allergenRows = await db.rawQuery('''
      SELECT DISTINCT a.name
      FROM allergens a
      JOIN ingredient_allergens ia ON ia.allergen_id = a.id
      JOIN food_ingredients fi ON fi.ingredient_id = ia.ingredient_id
      WHERE fi.food_id = ?
      ORDER BY a.name
    ''', [foodId]);

    final allergens = allergenRows.map((r) => r['name'] as String).toList();

    return FoodDbResult(ingredients: ingredients, allergens: allergens);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvoidedAllergensProvider extends ChangeNotifier {
  static const String _key = 'avoided_allergens';

  final List<String> _avoided = [];

  List<String> get avoided => List.unmodifiable(_avoided);

  AvoidedAllergensProvider() {
    loadAvoidedAllergens();
  }

  Future<void> loadAvoidedAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];

    _avoided
      ..clear()
      ..addAll(saved);

    notifyListeners();
  }

  Future<void> _saveAvoidedAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _avoided);
  }

  bool isAvoided(String allergen) {
    return _avoided.contains(allergen);
  }

  Future<void> toggle(String allergen) async {
    if (_avoided.contains(allergen)) {
      _avoided.remove(allergen);
    } else {
      _avoided.add(allergen);
    }

    await _saveAvoidedAllergens();
    notifyListeners();
  }

  Future<void> remove(String allergen) async {
    _avoided.remove(allergen);
    await _saveAvoidedAllergens();
    notifyListeners();
  }

  Future<void> clear() async {
    _avoided.clear();
    await _saveAvoidedAllergens();
    notifyListeners();
  }

  Future<void> setAvoided(List<String> allergens) async {
    _avoided
      ..clear()
      ..addAll(allergens);

    await _saveAvoidedAllergens();
    notifyListeners();
  }
}

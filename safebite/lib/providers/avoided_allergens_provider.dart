import 'package:flutter/material.dart';

class AvoidedAllergensProvider extends ChangeNotifier {
  final List<String> _avoided = [];

  List<String> get avoided => List.unmodifiable(_avoided);

  bool isAvoided(String allergen) {
    return _avoided.contains(allergen);
  }

  void toggle(String allergen) {
    if (_avoided.contains(allergen)) {
      _avoided.remove(allergen);
    } else {
      _avoided.add(allergen);
    }
    notifyListeners();
  }

  void setAvoided(List<String> allergens) {
    _avoided
      ..clear()
      ..addAll(allergens);
    notifyListeners();
  }

  void remove(String allergen) {
    _avoided.remove(allergen);
    notifyListeners();
  }

  void clear() {
    _avoided.clear();
    notifyListeners();
  }
}

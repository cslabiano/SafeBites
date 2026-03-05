class AllergenChecker {
  static bool isUnsafe(
    List<String> foodAllergens,
    List<String> userAllergens,
  ) {
    for (var allergen in foodAllergens) {
      if (userAllergens.contains(allergen)) {
        return true;
      }
    }

    return false;
  }
}

class AllergenEmoji {
  static const Map<String, String> _emojiMap = {
    'milk': '🥛',
    'egg': '🥚',
    'peanut': '🥜',
    'soy': '🌿',
    'wheat': '🌾',
    'tree nut': '🌰',
    'shellfish': '🦐',
    'fish': '🐟',
    'sesame': '🌱',
  };

  static String get(String name) {
    return _emojiMap[name.toLowerCase()] ?? '⚠️';
  }
}

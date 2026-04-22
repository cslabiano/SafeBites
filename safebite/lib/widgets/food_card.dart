import 'package:flutter/material.dart';
import '../screens/allergens/allergen_emoji.dart';

class FoodCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String ingredients;
  final bool hasAlert;
  final List<String> allergenLabels;
  final List<String> triggeredAllergens;

  const FoodCard({
    super.key,
    required this.onTap,
    required this.title,
    required this.ingredients,
    this.hasAlert = false,
    this.allergenLabels = const [],
    this.triggeredAllergens = const [],
  });

  String _getFoodEmoji() {
    if (allergenLabels.isEmpty) return '🍜';
    return AllergenEmoji.get(allergenLabels.first);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getFoodEmoji(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontFamilyFallback: [
                      'Segoe UI Emoji',
                      'Noto Color Emoji',
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: hasAlert
                                ? const Color.fromRGBO(250, 227, 226, 1)
                                : const Color.fromRGBO(230, 250, 238, 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasAlert
                                    ? Icons.warning_amber_rounded
                                    : Icons.gpp_good_outlined,
                                size: 12,
                                color: hasAlert
                                    ? const Color.fromRGBO(145, 31, 27, 1)
                                    : const Color.fromRGBO(46, 125, 50, 1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasAlert ? 'ALERT' : 'SAFE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: hasAlert
                                      ? const Color.fromRGBO(145, 31, 27, 1)
                                      : const Color.fromRGBO(46, 125, 50, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ingredients,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

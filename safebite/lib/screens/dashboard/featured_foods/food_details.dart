import 'package:flutter/material.dart';

class FoodDetailsPage extends StatelessWidget {
  final String title;
  final String ingredients;
  final String? sourceLink;

  const FoodDetailsPage({
    super.key,
    required this.title,
    required this.ingredients,
    this.sourceLink,
  });

  @override
  Widget build(BuildContext context) {
    final ingredientList = ingredients
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (ingredientList.isEmpty)
              const Text('No ingredients available.')
            else
              ...ingredientList.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(ingredient)),
                    ],
                  ),
                ),
              ),
            if (sourceLink != null && sourceLink!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(sourceLink!),
            ],
          ],
        ),
      ),
    );
  }
}

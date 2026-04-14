import 'package:flutter/material.dart';

class AllergenDetailsPage extends StatelessWidget {
  final String title;
  final String information;
  final String? sourceLink;

  const AllergenDetailsPage({
    super.key,
    required this.title,
    required this.information,
    this.sourceLink,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergen Details'),
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
              'Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              information.isNotEmpty
                  ? information
                  : 'No additional information available.',
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

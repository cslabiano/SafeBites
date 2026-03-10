import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodDetailsPage extends StatelessWidget {
  final String title;
  final String ingredients;
  final String? sourceLink;
  const FoodDetailsPage(
      {required this.title,
      required this.ingredients,
      this.sourceLink,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(ingredients),
              if (sourceLink != null)
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(sourceLink!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    sourceLink!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}

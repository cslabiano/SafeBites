import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AllergenDetailsPage extends StatelessWidget {
  final String title;
  final String information;
  final String? sourceLink;
  const AllergenDetailsPage(
      {required this.title,
      required this.information,
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
              Text(information),
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

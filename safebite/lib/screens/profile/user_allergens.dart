import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebite/providers/allergies_provider.dart';
import 'package:safebite/widgets/button.dart';
import 'allergen_dialog.dart';

class UserAllergens extends StatelessWidget {
  const UserAllergens({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.secondary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 18,
                    color: Color.fromRGBO(240, 158, 12, 1),
                  ),
                  SizedBox(width: 4),
                  Text("Food Allergens", style: TextStyle(fontSize: 16)),
                ],
              ),
              Button(
                  callback: () async {
                    showDialog(
                      context: context,
                      builder: (context) => const AllergenDialog(),
                    );
                  },
                  text: "Edit",
                  type: "text"),
            ],
          ),
          const Text(
            "Manage your food allergies and dietary restrictions",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          Consumer<AllergiesProvider>(
            builder: (context, allergiesProvider, child) {
              final allergies = allergiesProvider.allergies;

              return Wrap(
                spacing: 8,
                children: allergies.map((a) {
                  return Chip(
                    label: Text(a,
                        style: TextStyle(color: theme.colorScheme.primary)),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.transparent)),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

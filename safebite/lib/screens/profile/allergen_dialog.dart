import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebite/providers/allergies_provider.dart';

class AllergenDialog extends StatefulWidget {
  const AllergenDialog({super.key});

  @override
  State<AllergenDialog> createState() => _AllergenDialogState();
}

class _AllergenDialogState extends State<AllergenDialog> {
  Set<String> selectedAllergens = {};

  @override
  void initState() {
    super.initState();

    final allergies = context.read<AllergiesProvider>().allergies;

    selectedAllergens = allergies.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final allergens = [
      "Milk",
      "Egg",
      "Peanut",
      "Soy",
      "Wheat",
      "Fish",
      "Shellfish",
      "Sesame",
      "Tree Nut",
    ];

    return AlertDialog(
      title: const Text("Select Allergens"),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView(
          children: allergens.map((allergen) {
            return CheckboxListTile(
              title: Text(allergen),
              value: selectedAllergens.contains(allergen),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedAllergens.add(allergen);
                  } else {
                    selectedAllergens.remove(allergen);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final allergiesProvider = context.read<AllergiesProvider>();

            await allergiesProvider.setAllergies(
              selectedAllergens.toList(),
            );

            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

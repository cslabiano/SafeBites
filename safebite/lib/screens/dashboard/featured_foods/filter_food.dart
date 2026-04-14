import 'package:flutter/material.dart';

class FilterFoodSheet extends StatefulWidget {
  final List<Map<String, dynamic>> allergens;
  final List<String> initiallySelected;

  const FilterFoodSheet({
    super.key,
    required this.allergens,
    required this.initiallySelected,
  });

  @override
  State<FilterFoodSheet> createState() => _FilterFoodSheetState();
}

class _FilterFoodSheetState extends State<FilterFoodSheet> {
  late List<String> tempSelection;

  @override
  void initState() {
    super.initState();
    tempSelection = List<String>.from(widget.initiallySelected);
  }

  void _toggleAllergen(String allergenName, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!tempSelection.contains(allergenName)) {
          tempSelection.add(allergenName);
        }
      } else {
        tempSelection.remove(allergenName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exclude allergens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose one or more allergens to exclude from today’s featured foods.',
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.allergens.map((allergen) {
                    final allergenName = allergen['name']?.toString() ?? '';
                    final isSelected = tempSelection.contains(allergenName);

                    return CheckboxListTile(
                      value: isSelected,
                      contentPadding: EdgeInsets.zero,
                      title: Text(allergenName),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) {
                        _toggleAllergen(allergenName, checked ?? false);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempSelection.clear();
                    });
                  },
                  child: const Text('Clear all'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, tempSelection);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/allergen_card.dart';
import 'allergen_details.dart';

class AllergensSection extends StatelessWidget {
  final List allergens;

  const AllergensSection({
    super.key,
    required this.allergens,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allergens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final allergen = allergens[index];

        return AllergenCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllergenDetailsPage(
                  title: allergen["name"],
                  information: allergen["more_information"] ?? '',
                  sourceLink: allergen["source_link"],
                ),
              ),
            );
          },
          title: allergen["name"],
          subtitle: allergen["short_description"] ?? "",
          iconData: Icons.warning_amber_outlined,
          iconColor: const Color.fromRGBO(240, 158, 12, 1),
        );
      },
    );
  }
}

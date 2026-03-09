import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String ingredients;
  const FoodCard(
      {required this.onTap,
      required this.title,
      required this.ingredients,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors
          .transparent, // Ensures the Material background doesn't interfere
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Ink(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.secondary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the left
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .start, // No spaceBetween needed as there is no Edit button
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  // Added an invisible expanded widget to push content left
                  // and fill space, if necessary, but focusing on content alignment
                ],
              ),
              const SizedBox(
                  height: 4), // Small vertical space between title and subtitle
              Row(
                children: [
                  const Text(
                    "Ingredients: ",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  Expanded(
                    child: Text(
                      ingredients,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

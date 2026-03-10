import 'package:flutter/material.dart';

class AllergenCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color iconColor;

  const AllergenCard({
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // InkWell and Material are used together to allow for the ripple effect
    // while maintaining the custom border styling on the card itself.
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
                  Icon(
                    iconData,
                    size: 18,
                    color: iconColor,
                  ),
                  const SizedBox(width: 8),
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
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

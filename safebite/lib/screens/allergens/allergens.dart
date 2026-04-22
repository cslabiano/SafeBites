import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebite/screens/allergens/allergen_emoji.dart';

import '../../providers/avoided_allergens_provider.dart';
import '../dashboard/dashboard_controller.dart';
import 'allergen_details.dart';

class Allergens extends StatefulWidget {
  const Allergens({super.key});

  @override
  State<Allergens> createState() => _AllergensState();
}

class _AllergensState extends State<Allergens> {
  final DashboardController controller = DashboardController();

  List<Map<String, dynamic>> allergens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    setState(() {
      _isLoading = true;
    });

    final result = await controller.loadAllergens();

    if (!mounted) return;

    setState(() {
      allergens = List<Map<String, dynamic>>.from(result);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avoidedProvider = context.watch<AvoidedAllergensProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAllergens,
        child: _isLoading
            ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 120),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: allergens.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Text(
                          'Allergens',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Tap the toggle to add an allergen to your avoid list. Tap the card to learn more.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }

                  final allergen = allergens[index - 1];
                  final allergenName = allergen['name']?.toString() ?? '';
                  final isAvoided = avoidedProvider.isAvoided(allergenName);

                  return Material(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 1.5,
                    shadowColor: Colors.black.withOpacity(0.08),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllergenDetailsPage(
                              title: allergenName,
                              information: allergen['more_information'] ?? '',
                              sourceLink: allergen['source_link'],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                AllergenEmoji.get(allergenName),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontFamilyFallback: [
                                    'Segoe UI Emoji',
                                    'Noto Color Emoji',
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    allergenName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    allergen['short_description'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {
                                avoidedProvider.toggle(allergenName);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                side: BorderSide(
                                  color: isAvoided
                                      ? const Color.fromRGBO(145, 31, 27, 1)
                                      : Colors.grey.shade300,
                                ),
                                backgroundColor: isAvoided
                                    ? const Color.fromRGBO(145, 31, 27, 1)
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                isAvoided ? 'AVOIDING' : 'AVOID',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isAvoided ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

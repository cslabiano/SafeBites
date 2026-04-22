import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'allergen_card.dart';

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

                  return AllergenCard(
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
                    onToggle: () {
                      avoidedProvider.toggle(allergenName);
                    },
                    title: allergenName,
                    subtitle: allergen['short_description'] ?? '',
                    isAvoided: isAvoided,
                  );
                },
              ),
      ),
    );
  }
}

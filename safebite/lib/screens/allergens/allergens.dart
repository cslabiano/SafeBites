import 'package:flutter/material.dart';

import '../../widgets/allergen_card.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Common Allergens',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
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
            : allergens.isEmpty
                ? const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('No allergens found.'),
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                                title: allergen['name'],
                                information: allergen['more_information'] ?? '',
                                sourceLink: allergen['source_link'],
                              ),
                            ),
                          );
                        },
                        title: allergen['name'],
                        subtitle: allergen['short_description'] ?? '',
                        iconData: Icons.warning_amber_outlined,
                        iconColor: const Color.fromRGBO(240, 158, 12, 1),
                      );
                    },
                  ),
      ),
    );
  }
}

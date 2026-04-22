import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../database/food_repository.dart';
import '../../providers/avoided_allergens_provider.dart';
import '../allergens/allergen_emoji.dart';
import '../dashboard/food_details.dart';

class AllergenDetailsPage extends StatefulWidget {
  final String title;
  final String information;
  final String? sourceLink;

  const AllergenDetailsPage({
    super.key,
    required this.title,
    required this.information,
    this.sourceLink,
  });

  @override
  State<AllergenDetailsPage> createState() => _AllergenDetailsPageState();
}

class _AllergenDetailsPageState extends State<AllergenDetailsPage> {
  final FoodRepository repo = FoodRepository();

  List<Map<String, dynamic>> foods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final result = await repo.getFoodsByAllergen(widget.title);

    if (!mounted) return;

    setState(() {
      foods = result;
      isLoading = false;
    });
  }

  List<String> _extractAllergens(Map<String, dynamic> food) {
    final raw = food['allergens'];

    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (raw is String) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AvoidedAllergensProvider>();
    final isAvoided = provider.avoided.contains(widget.title);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Allergen info',
          style: TextStyle(fontSize: 16),
        ),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CONTENT
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      AllergenEmoji.get(widget.title),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            if (isAvoided) {
                              provider.remove(widget.title);
                            } else {
                              provider.setAvoided(
                                  [...provider.avoided, widget.title]);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAvoided
                                  ? const Color.fromRGBO(220, 72, 56, 1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isAvoided
                                    ? const Color.fromRGBO(220, 72, 56, 1)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              isAvoided ? 'AVOIDING' : 'TAP TO AVOID',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color:
                                    isAvoided ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ABOUT
              Text(
                'ABOUT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.information.isNotEmpty
                    ? widget.information
                    : 'No additional information available.',
              ),

              const SizedBox(height: 24),

              // DISHES SECTION
              Text(
                'FILIPINO DISHES THAT CONTAIN IT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 10),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (foods.isEmpty)
                const Text('None in our database.')
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: foods.asMap().entries.map((entry) {
                      final index = entry.key;
                      final food = entry.value;
                      final allergenLabels = _extractAllergens(food);
                      final isLast = index == foods.length - 1;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodDetailsPage(
                                title: food['name'],
                                ingredients: food['ingredients'] ?? '',
                                sourceLink: food['source_link']?.toString(),
                                allergenLabels: allergenLabels,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  food['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              const Text(
                                'View →',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(82, 167, 107, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../widgets/searchbar.dart';
import 'dashboard_controller.dart';

import 'widgets/daily_food.dart';
import 'widgets/allergens_section.dart';
import 'widgets/search_results.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  final DashboardController controller = DashboardController();

  String _searchText = '';

  List<Map<String, dynamic>> allergens = [];
  List<Map<String, dynamic>> featuredFoods = [];
  List<Map<String, dynamic>> foods = [];
  List<String> selectedExcludedAllergens = [];

  bool _isLoadingFeaturedFoods = true;
  bool _isLoadingAllergens = true;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  Future<void> _initializeDashboard() async {
    await Future.wait([
      loadAllergens(),
      loadFeaturedFoods(),
    ]);
  }

  Future<void> loadAllergens() async {
    setState(() {
      _isLoadingAllergens = true;
    });

    final result = await controller.loadAllergens();

    if (!mounted) return;

    setState(() {
      allergens = List<Map<String, dynamic>>.from(result);
      _isLoadingAllergens = false;
    });
  }

  Future<void> loadFeaturedFoods() async {
    setState(() {
      _isLoadingFeaturedFoods = true;
    });

    final result = await controller.loadFeaturedFoods(
      excludedAllergens: selectedExcludedAllergens,
    );

    if (!mounted) return;

    setState(() {
      featuredFoods = List<Map<String, dynamic>>.from(result);
      _isLoadingFeaturedFoods = false;
    });
  }

  Future<void> _handleSearch(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      if (!mounted) return;

      setState(() {
        foods = [];
      });
      return;
    }

    final results = await controller.searchFoods(trimmedQuery);

    if (!mounted) return;

    setState(() {
      foods = List<Map<String, dynamic>>.from(results);
    });
  }

  void _handleClear() {
    _searchController.clear();

    setState(() {
      foods = [];
      _searchText = '';
    });
  }

  Future<void> _openFeaturedFoodFilter() async {
    final tempSelection = List<String>.from(selectedExcludedAllergens);

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          children: allergens.map((allergen) {
                            final allergenName =
                                allergen['name']?.toString() ?? '';

                            final isSelected =
                                tempSelection.contains(allergenName);

                            return CheckboxListTile(
                              value: isSelected,
                              contentPadding: EdgeInsets.zero,
                              title: Text(allergenName),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    if (!tempSelection.contains(allergenName)) {
                                      tempSelection.add(allergenName);
                                    }
                                  } else {
                                    tempSelection.remove(allergenName);
                                  }
                                });
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
                            setModalState(() {
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
          },
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      selectedExcludedAllergens = result;
    });

    await loadFeaturedFoods();
  }

  Widget _buildSelectedFilters(ThemeData theme) {
    if (selectedExcludedAllergens.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectedExcludedAllergens.map((allergen) {
          return Chip(
            label: Text(allergen),
            onDeleted: () async {
              setState(() {
                selectedExcludedAllergens.remove(allergen);
              });
              await loadFeaturedFoods();
            },
            backgroundColor: theme.colorScheme.secondaryContainer,
            labelStyle: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'SafeBite',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Search foods and view allergen information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBarWidget(
              controller: _searchController,
              onChanged: _handleSearch,
              onClear: _handleClear,
              hintText: 'Search food or ingredient',
            ),
            const SizedBox(height: 20),
            if (_searchText.isEmpty) ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Featured Foods',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        allergens.isEmpty ? null : _openFeaturedFoodFilter,
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: const Text('Filter'),
                  ),
                ],
              ),
              _buildSelectedFilters(theme),
              const SizedBox(height: 10),
              if (_isLoadingFeaturedFoods)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                DailyFoodSection(
                  foods: featuredFoods,
                  repo: controller.repo,
                ),
              const SizedBox(height: 20),
              const Text(
                'Common Allergens',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoadingAllergens)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                AllergensSection(
                  allergens: allergens,
                ),
            ] else
              SearchResults(
                foods: foods,
                repo: controller.repo,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () {
          Navigator.pushNamed(context, '/camera');
        },
        child: const Icon(Icons.camera_alt_rounded),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../widgets/searchbar.dart';
import 'dashboard_controller.dart';
import 'dashboard_header.dart';
import 'search_results.dart';
import 'featured_foods/featured_section.dart';
import 'featured_foods/filter_food.dart';
import 'allergens_section/allergens_section.dart';

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
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return FilterFoodSheet(
          allergens: allergens,
          initiallySelected: selectedExcludedAllergens,
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      selectedExcludedAllergens = result;
    });

    await loadFeaturedFoods();
  }

  Future<void> _removeExcludedAllergen(String allergen) async {
    setState(() {
      selectedExcludedAllergens.remove(allergen);
    });

    await loadFeaturedFoods();
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
      appBar: const DashboardHeader(),
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
              FeaturedSection(
                foods: featuredFoods,
                repo: controller.repo,
                allergens: allergens,
                selectedExcludedAllergens: selectedExcludedAllergens,
                isLoading: _isLoadingFeaturedFoods,
                onOpenFilter: _openFeaturedFoodFilter,
                onRemoveAllergen: _removeExcludedAllergen,
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

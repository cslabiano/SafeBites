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

  @override
  void initState() {
    super.initState();

    loadAllergens();
    loadFeaturedFoods();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  Future<void> loadAllergens() async {
    final result = await controller.loadAllergens();

    if (!mounted) return;

    setState(() {
      allergens = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> loadFeaturedFoods() async {
    final result = await controller.loadFeaturedFoods(
      excludedAllergens: selectedExcludedAllergens,
    );

    if (!mounted) return;

    setState(() {
      featuredFoods = result;
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
            /// SEARCH BAR
            SearchBarWidget(
              controller: _searchController,
              onChanged: _handleSearch,
              onClear: _handleClear,
              hintText: 'Search food or ingredient',
            ),

            const SizedBox(height: 20),

            /// DEFAULT DASHBOARD
            if (_searchText.isEmpty) ...[
              const Text(
                'Featured Foods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
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
              AllergensSection(
                allergens: allergens,
              ),
            ]

            /// SEARCH RESULTS
            else
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

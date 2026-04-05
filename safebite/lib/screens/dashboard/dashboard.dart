import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebite/providers/allergies_provider.dart';

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
  List<Map<String, dynamic>> safeDailyFoods = [];
  List<Map<String, dynamic>> foods = [];

  List<String> _lastLoadedAllergies = [];

  @override
  void initState() {
    super.initState();

    loadAllergens();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });

    /// Fetch allergies initially
    Future.microtask(() async {
      final allergiesProvider = context.read<AllergiesProvider>();
      await allergiesProvider.fetchAllergies();
    });
  }

  Future<void> loadAllergens() async {
    final result = await controller.loadAllergens();

    setState(() {
      allergens = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> loadSafeFoods(List<String> allergies) async {
    final dailyFoods = await controller.loadDailyFoods(allergies);

    setState(() {
      safeDailyFoods = dailyFoods;
    });
  }

  Future<void> _handleSearch(String query) async {
    final results = await controller.searchFoods(query);

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenHeight = MediaQuery.of(context).size.height;

    /// WATCH PROVIDER (this triggers rebuild when allergies change)
    final allergiesProvider = context.watch<AllergiesProvider>();
    final currentAllergies = allergiesProvider.allergies;

    /// Reload safe foods only if allergies changed
    if (_lastLoadedAllergies.toString() != currentAllergies.toString() ||
        safeDailyFoods.isEmpty) {
      _lastLoadedAllergies = List.from(currentAllergies);
      Future.microtask(() => loadSafeFoods(currentAllergies));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            "Dashboard",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Stay safe with personalized food recommendations",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            /// SEARCH BAR
            SearchBarWidget(
              controller: _searchController,
              onChanged: _handleSearch,
              onClear: _handleClear,
              hintText: "Search food, ingredients, or allergen",
            ),

            const SizedBox(height: 20),

            /// DEFAULT DASHBOARD
            if (_searchText.isEmpty) ...[
              const Text(
                "Today's Safe Picks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              DailyFoodSection(
                foods: safeDailyFoods,
                repo: controller.repo,
              ),
              const SizedBox(height: 20),
              const Text(
                "Common Allergens",
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/avoided_allergens_provider.dart';
import '../../widgets/searchbar.dart';
import 'dashboard_controller.dart';
import 'dashboard_header.dart';
import 'search_results.dart';
import 'featured_section.dart';
import 'filter_food.dart';

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

  bool _isLoadingFeaturedFoods = true;

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

  Future<void> _toggleExcludedAllergen(String allergen) async {
    final provider = context.read<AvoidedAllergensProvider>();

    if (provider.isAvoided(allergen)) {
      provider.remove(allergen);
    } else {
      provider.setAvoided([...provider.avoided, allergen]);
    }

    await loadFeaturedFoods();
  }

  Future<void> _initializeDashboard() async {
    await loadAllergens();
    await loadFeaturedFoods();
  }

  Future<void> loadAllergens() async {
    final result = await controller.loadAllergens();

    if (!mounted) return;

    setState(() {
      allergens = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> loadFeaturedFoods() async {
    final avoided = context.read<AvoidedAllergensProvider>().avoided;

    setState(() {
      _isLoadingFeaturedFoods = true;
    });

    final result = await controller.loadFeaturedFoods(
      excludedAllergens: avoided,
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
    final provider = context.read<AvoidedAllergensProvider>();

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return FilterFoodSheet(
          allergens: allergens,
          initiallySelected: provider.avoided,
        );
      },
    );

    if (result == null || !mounted) return;

    provider.setAvoided(result);
    await loadFeaturedFoods();
  }

  Future<void> _removeExcludedAllergen(String allergen) async {
    context.read<AvoidedAllergensProvider>().remove(allergen);
    await loadFeaturedFoods();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.watch<AvoidedAllergensProvider>().avoided;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        loadFeaturedFoods();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avoided = context.watch<AvoidedAllergensProvider>().avoided;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 20,
              16,
              20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(49, 145, 105, 1),
                  Color.fromRGBO(87, 166, 132, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const SizedBox(height: 16),
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  onClear: _handleClear,
                  hintText: 'Search food or ingredient',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_searchText.isEmpty)
                    FeaturedSection(
                      foods: featuredFoods,
                      repo: controller.repo,
                      allergens: allergens,
                      selectedExcludedAllergens: avoided,
                      isLoading: _isLoadingFeaturedFoods,
                      onToggleAllergen: _toggleExcludedAllergen,
                    )
                  else
                    SearchResults(
                      foods: foods,
                      repo: controller.repo,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

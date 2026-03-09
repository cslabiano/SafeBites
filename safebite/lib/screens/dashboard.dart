import 'package:flutter/material.dart';
import 'package:safebite/screens/allergen_details.dart';
import '../widgets/allergen_card.dart';
import '../widgets/searchbar.dart';
import '../database/food_repository.dart';
import '../widgets/food_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  final FoodRepository repo = FoodRepository();
  List allergens = [];
  List foods = [];

  @override
  void initState() {
    super.initState();

    loadAllergens();

    // listen for text changes to update the state and redraw the clear button
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  void _handleClear() {
    _searchController.clear();
    setState(() {});
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        foods = [];
      });
      return;
    }

    var results = await repo.searchFoods(query);

    setState(() {
      foods = results;
    });
  }

  Future<void> loadAllergens() async {
    var result = await repo.getAllergens();

    setState(() {
      allergens = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final theme = Theme.of(context);

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
                  color: theme.colorScheme.primary),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Stay safe with personalized food recommendations",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
                SizedBox(height: screenHeight * 0.03),

                // search bar
                SearchBarWidget(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    onClear: _handleClear,
                    hintText: "Search food, ingredients, or allergen"),

                // default dashboard when search is empty
                if (_searchText.isEmpty)

                  // View today's top three recommendations

                  // View list of common allergens
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allergens.length,
                    itemBuilder: (context, index) {
                      var allergen = allergens[index];

                      return AllergenCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllergenDetailsPage(
                                  title: allergen["name"],
                                  information: allergen["more_information"],
                                  sourceLink: allergen["source_link"]),
                            ),
                          );
                        },
                        title: allergen["name"],
                        subtitle: allergen["short_description"] ?? "",
                        iconData: Icons.warning_amber_outlined,
                        iconColor: const Color.fromRGBO(240, 158, 12, 1),
                      );
                    },
                  )

                // display search results
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      var food = foods[index];

                      return FoodCard(
                        onTap: () {
                          // optional: open food details page
                        },
                        title: food["name"],
                        ingredients: food["ingredients"] ?? "",
                      );
                    },
                  ),
              ],
            )));
  }
}

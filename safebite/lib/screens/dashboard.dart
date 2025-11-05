import 'package:flutter/material.dart';
import '../widgets/allergen_card.dart';
import '../widgets/searchbar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
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

  void _handleSearch(String query) {
    print('Searching for: $query');
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
                SizedBox(height: screenHeight * 0.3),

                // search bar
                SearchBarWidget(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    onClear: _handleClear,
                    hintText: "Search food, ingredients, or allergen"),

                // default dashboard when search is empty
                if (_searchText.isEmpty) 
                  AllergenCard(
                    onTap: () {},
                    title: "Milk",
                    subtitle:
                        "Allergy to cow's milk is the most common food allergy in infants and young children. About 2.5 percent of children under age 3 are allergic to milk, and most of these children develop milk allergy in their first year of life",
                    iconData: Icons.warning_amber_outlined,
                    iconColor: const Color.fromRGBO(240, 158, 12, 1),
                  )

                // display search results
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        "Searching results for \"$_searchText\"...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ),
                  ),
              ],
            )));
  }
}

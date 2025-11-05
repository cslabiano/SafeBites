import 'package:flutter/material.dart';
import 'package:safebite/widgets/button.dart';
import 'package:provider/provider.dart';
import 'package:safebite/providers/auth_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // User? user;

  Future<void> _navigateToAuth() async {
    await context.read<UserAuthProvider>().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    // user = context.read<UserAuthProvider>().user;
    const String user = "Myndie";
    const String email = "myndie@gmail.com";

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            "Profile",
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
            const Text("Manage your allergen profile and settings",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),

            // displays name and email in a card
            SizedBox(height: screenHeight * 0.03),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12.0)),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(100.0)),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.primary,
                      )),
                  SizedBox(width: screenWidth * 0.05),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                      Text(email,
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // displays user's food allergens
            SizedBox(height: screenHeight * 0.03),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12.0)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 18,
                            color: Color.fromRGBO(240, 158, 12, 1),
                          ),
                          SizedBox(width: 4),
                          Text("Food Allergens",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Button(callback: () async {}, text: "Edit", type: "text"),
                    ],
                  ),
                  const Text(
                    "Manage your food allergies and dietary restrictions",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),

            // displays safety reminders
            SizedBox(height: screenHeight * 0.03),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(250, 227, 226, 1),
                  border: Border.all(
                    color: Color.fromRGBO(253, 198, 196, 1),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Safety Reminders",
                      style: TextStyle(
                          color: Color.fromRGBO(145, 31, 27, 1), fontSize: 16)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 17),
                      Expanded(
                          child: Text(
                              "Carry emergency medication if prescribed.",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(145, 31, 27, 1)))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 17),
                      Expanded(
                          child: Text("Keep your allergen profile updated.",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(145, 31, 27, 1)))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 17),
                      Expanded(
                          child: Text(
                              "This app is not an alternative to a professional advice. SafeBite aims to give help users make informed choices.",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(145, 31, 27, 1)))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(
          callback: _navigateToAuth,
          text: "Sign Out",
          type: "outlined",
        ),
      ),
    );
  }
}

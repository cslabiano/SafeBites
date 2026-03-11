import 'package:firebase_auth/firebase_auth.dart';
import 'package:safebite/models/user_model.dart';
import 'package:safebite/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:safebite/widgets/button.dart';

import 'safety_reminders.dart';
import 'user_details.dart';
import 'user_allergens.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> _navigateToAuth() async {
    await context.read<UserAuthProvider>().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserAuthProvider>();
    final nickname = userProvider.nickname ?? 'loading...';
    final email = userProvider.user?.email ?? 'loading...';
    final allergies = userProvider.allergies ?? [];

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
            UserDetails(nickname: nickname, email: email),

            // displays user's food allergens
            SizedBox(height: screenHeight * 0.03),
            UserAllergens(),

            // displays safety reminders
            SizedBox(height: screenHeight * 0.03),
            const SafetyReminders(),
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

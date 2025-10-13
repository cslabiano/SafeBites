import 'package:flutter/material.dart';

// import screens
import 'screens/auth/sign_in.dart';
import 'screens/auth/sign_up.dart';
import 'navbar.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeBite',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          background: Color.fromRGBO(240, 253, 250, 1),
          onBackground: Color.fromRGBO(15, 23, 42, 1),
          primary: Color.fromRGBO(13, 148, 136, 1),
          onPrimary: Colors.white,
          secondary: Color.fromRGBO(240, 253, 250, 1),
          onSecondary: Color.fromRGBO(15, 23, 42, 1),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignIn(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/navbar': (context) => const Navbar(),
        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}

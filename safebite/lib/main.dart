import 'package:firebase_core/firebase_core.dart';
import 'package:safebite/firebase_options.dart';
import 'package:flutter/material.dart';

// import screens
import 'screens/auth/sign_in.dart';
import 'screens/auth/sign_up.dart';
import 'navbar.dart';
import 'screens/dashboard.dart';
import 'screens/profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: ((context) => UserAuthProvider())),
  //       ChangeNotifierProvider(create: ((context) => DonationProvider())),
  //       ChangeNotifierProvider(create: ((context) => DonorProvider())),
  //       ChangeNotifierProvider(create: ((context) => DonationDriveProvider())),
  //       ChangeNotifierProvider(create: ((context) => OrganizationProvider())),
  //       ChangeNotifierProvider(create: ((context) => AdminProvider()))
  //     ],
  //     child: const MainApp(),
  //   ),
  // );

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
          secondary: Color.fromRGBO(213, 250, 241, 1),
          onSecondary: Color.fromRGBO(15, 23, 42, 1),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Navbar(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/navbar': (context) => const Navbar(),
        '/dashboard': (context) => const Dashboard(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}

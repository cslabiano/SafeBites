import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:safebite/firebase_options.dart';
import 'package:flutter/material.dart';

// import providers
import 'package:safebite/providers/auth_provider.dart';

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

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserAuthProvider(),
      child: const MyApp(), // Your root application widget
    ),
    // MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: ((context) => UserAuthProvider())),
    //   ],
    //   child: const MyApp(),
    // ),
  );

  // runApp(const MyApp());
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
        '/': (context) => const AuthGate(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/navbar': (context) => const Navbar(),
        '/dashboard': (context) => const Dashboard(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    return StreamBuilder(
      stream: authProvider.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const SignIn();
        }
        return const Navbar();
      },
    );
  }
}

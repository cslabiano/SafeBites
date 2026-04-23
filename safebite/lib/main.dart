import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:safebite/providers/avoided_allergens_provider.dart';

import 'splash_screen.dart';

late final List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AvoidedAllergensProvider(),
      child: MyApp(cameras: cameras),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeBite',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          background: Color.fromRGBO(249, 253, 252, 1),
          onBackground: Color.fromRGBO(15, 23, 42, 1),
          primary: Color.fromRGBO(49, 145, 105, 1),
          onPrimary: Colors.white,
          secondary: Color.fromRGBO(215, 243, 236, 1),
          onSecondary: Color.fromRGBO(15, 23, 42, 1),
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(cameras: cameras),
    );
  }
}

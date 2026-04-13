import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// import screens
import 'screens/dashboard/dashboard.dart';
import 'screens/camera/camera.dart';

late final List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeBite',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          // background: Color.fromRGBO(240, 253, 250, 1),
          background: Color.fromRGBO(255, 255, 255, 1),
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
        '/': (context) => const Dashboard(),
        '/camera': (context) => Camera(cameras: cameras),
      },
    );
  }
}

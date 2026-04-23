import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'navbar.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SplashScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToApp();
  }

  Future<void> _goToApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Navbar(cameras: widget.cameras),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Text(
          'SafeBite',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'screens/dashboard/dashboard.dart';
import 'screens/camera/camera.dart';
import 'screens/profile/profile.dart';

class Navbar extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Navbar({
    super.key,
    required this.cameras,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Dashboard(),
      Camera(cameras: widget.cameras),
      const Profile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home)
                : const Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? const Icon(Icons.photo_camera)
                : const Icon(Icons.photo_camera_outlined),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? const Icon(Icons.person)
                : const Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

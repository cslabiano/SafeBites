import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SafeBite',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            color: Colors.white,
          ),
        ),
        Text(
          'Eat safer. Search foods and discover safe picks.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

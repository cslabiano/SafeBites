import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          'SafeBite',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 28,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(20),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Search foods and view allergen information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

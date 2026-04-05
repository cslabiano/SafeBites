import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  final String nickname;
  final String email;
  const UserDetails({required this.nickname, required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.secondary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0)),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(100.0)),
              child: Icon(
                Icons.person,
                size: 32,
                color: theme.colorScheme.primary,
              )),
          SizedBox(width: screenWidth * 0.05),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nickname,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16)),
              Text(email,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

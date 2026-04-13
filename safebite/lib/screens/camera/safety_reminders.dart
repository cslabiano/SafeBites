import 'package:flutter/material.dart';

class SafetyReminders extends StatelessWidget {
  const SafetyReminders({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(250, 227, 226, 1),
          border: Border.all(
            color: const Color.fromRGBO(253, 198, 196, 1),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Safety Reminders",
              style: TextStyle(
                  color: Color.fromRGBO(145, 31, 27, 1), fontSize: 16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_right, size: 17),
              Expanded(
                  child: Text("Carry emergency medication if prescribed.",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(145, 31, 27, 1)))),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_right, size: 17),
              Expanded(
                  child: Text("Keep your allergen profile updated.",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(145, 31, 27, 1)))),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_right, size: 17),
              Expanded(
                  child: Text(
                      "This app is not an alternative to a professional advice. SafeBite aims to help users make informed choices.",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(145, 31, 27, 1)))),
            ],
          ),
        ],
      ),
    );
  }
}

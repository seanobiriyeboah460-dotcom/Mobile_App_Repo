import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String name;
  final String title;

  const HeaderSection({super.key, required this.name, required this.title});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: Colors.amber[100],
          child: Icon(Icons.person, size: 50, color: Colors.blue),
        ),
        SizedBox(height: 16),
        Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 18, color: Colors.grey)),
      ],
    );
  }
}

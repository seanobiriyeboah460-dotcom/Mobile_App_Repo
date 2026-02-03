// fo/screens/portfolio_screen.dart
import 'package:flutter/material.dart';
import '../models/portfolio_data.dart';
import '../widgets/header_section.dart';
import '../widgets/education_section.dart';
import '../widgets/skills_section.dart';

class PortfolioScreen extends StatelessWidget {
  final PortfolioData data;

  const PortfolioScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Portfolio'),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Example action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications clicked')),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 16),
          children: [
            // Header Section
            HeaderSection(name: data.name, title: data.title),

            SizedBox(height: 16),

            // Bio Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(data.bio, style: TextStyle(fontSize: 16)),
                ),
              ),
            ),

            // Skills Section
            SkillsSection(skills: data.skills),

            // Education Section
            EducationSection(educationList: data.education),
          ],
        ),
      ),
    );
  }
}

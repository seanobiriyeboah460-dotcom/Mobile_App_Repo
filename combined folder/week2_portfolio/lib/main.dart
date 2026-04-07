import 'package:flutter/material.dart';
import 'screens/portfolio_screen.dart';
import 'models/portfolio_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioData = PortfolioData(
      name: 'Sean Obiri Yeboah',
      title: 'Level 300 Computer Science Student',
      bio: 'Brief Professional Bio.....',
      skills: ['Flutter', 'Dart', 'Firebase', 'Git', 'Rest APIs'],
      education: [
        Education(
          institution: 'Valley View University',
          degree: 'Bsc Computer Science',
          year: '2023-present',
        ),
      ],
    );
    return MaterialApp(
      title: 'Professional Portfolio',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: PortfolioScreen(data: portfolioData),
    );
  }
}

/* ==================================================  * COURSE: Mobile Application Development (INFT 425)  * INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah  * ==================================================  * This application was built as part of the formal course curriculum.  * Every major feature and implementation approach follows the  * structured guidance provided by the course instructor.  *  * Unauthorized reproduction or removal of this notice is a violation  * of academic integrity and professional attribution standards.  */

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mid Semester Exam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          primary: Colors.grey[400]!, // Silver for buttons
          surface: Colors.grey[100]!, // Light grey background
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

/* ==================================================  * COURSE: Mobile Application Development (INFT 425)  * INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah  * ==================================================  * This application was built as part of the formal course curriculum.  * Every major feature and implementation approach follows the  * structured guidance provided by the course instructor.  *  * Unauthorized reproduction or removal of this notice is a violation  * of academic integrity and professional attribution standards.  */

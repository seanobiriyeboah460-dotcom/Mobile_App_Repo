import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app
  runApp(const App());
}

/* ==================================================  * COURSE: Mobile Application Development (INFT 425)  * INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah  * ==================================================  * This application was built as part of the formal course curriculum.  * Every major feature and implementation approach follows the  * structured guidance provided by the course instructor.  *  * Unauthorized reproduction or removal of this notice is a violation  * of academic integrity and professional attribution standards.  */

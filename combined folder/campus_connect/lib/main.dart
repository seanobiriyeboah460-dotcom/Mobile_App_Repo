import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/event_viewmodel.dart';
import 'viewmodels/quote_viewmodel.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ← fixes constructor warning

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => QuoteViewModel()),
      ],
      child: MaterialApp(
        title: 'Campus Connect',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
      ),
    );
  }
}
/* ==================================================  * COURSE: Mobile Application Development (INFT 425)  * INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah  * ==================================================  * This application was built as part of the formal course curriculum.  * Every major feature and implementation approach follows the  * structured guidance provided by the course instructor.  *  * Unauthorized reproduction or removal of this notice is a violation  * of academic integrity and professional attribution standards.  */
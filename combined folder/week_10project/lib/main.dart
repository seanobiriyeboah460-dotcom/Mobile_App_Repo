import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'services/auto_lock_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          navigatorKey: AutoLockService.navigatorKey,
          title: 'Secure Notes',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: themeMode,
          home: const AuthScreen(),
        );
      },
    );
  }
}

/* ==================================================  * COURSE: Mobile Application Development (INFT 425)  * INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah  * ==================================================  * This application was built as part of the formal course curriculum.  * Every major feature and implementation approach follows the  * structured guidance provided by the course instructor.  *  * Unauthorized reproduction or removal of this notice is a violation  * of academic integrity and professional attribution standards.  */
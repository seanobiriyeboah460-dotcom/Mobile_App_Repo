import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/article_viewmodel.dart';
import 'views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArticleViewModel()..loadData(),
      child: MaterialApp(
        title: 'API Consumer App',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: const HomePage(),
      ),
    );
  }
}

/* ==================================================  * COURSE: Mobile Application Development (INFT 425)  * INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah  * ==================================================  * This application was built as part of the formal course curriculum.  * Every major feature and implementation approach follows the  * structured guidance provided by the course instructor.  *  * Unauthorized reproduction or removal of this notice is a violation  * of academic integrity and professional attribution standards.  */

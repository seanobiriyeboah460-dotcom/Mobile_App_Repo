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

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'screens/auth/login_screen.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('cart');
  await Hive.openBox('pendingOrders');
  runApp(const CampusEatsApp());
}

class CampusEatsApp extends StatefulWidget {
  const CampusEatsApp({super.key});

  @override
  State<CampusEatsApp> createState() => _CampusEatsAppState();
}

class _CampusEatsAppState extends State<CampusEatsApp> {
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    // Start listening for connectivity — handles offline queue sync
    _connectivityService = ConnectivityService();
    _connectivityService.init();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: MaterialApp(
        title: 'Campus Eats',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
        home: const LoginScreen(),
      ),
    );
  }
}

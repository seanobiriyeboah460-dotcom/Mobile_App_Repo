import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';

class AutoLockService {
  static const Duration timeout = Duration(minutes: 5);
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Timer? _timer;

  static void start() {
    _resetTimer();
  }

  static void userActivity() {
    if (_timer == null) {
      _resetTimer();
    } else {
      _resetTimer();
    }
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, _lockApp);
  }

  static void _lockApp() {
    stop();
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return;
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }
}

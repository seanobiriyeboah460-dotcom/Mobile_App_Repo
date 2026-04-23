import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final _service = AuthService();

  UserModel? currentUser;
  String? errorMessage;
  bool isLoading = false;

  bool get isAdmin => currentUser?.isAdmin ?? false;
  bool get isLoggedIn => currentUser != null;

  // Called on app start to restore session
  Future<void> restoreSession() async {
    try {
      currentUser = await _service.restoreSession();
    } catch (_) {
      currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Please enter your email and password.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _service.login(email, password);
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e.toString());
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Please fill in all fields.';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _service.signUp(email, password);
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e.toString());
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }

  // Converts Firebase error codes into readable messages
  String _friendlyError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}

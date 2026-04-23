import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserModel> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw Exception('Signup failed. Please try again.');
      }

      final uid = user.uid;

      // Create user document in Firestore
      await _db.collection('users').doc(uid).set({
        'email': email,
        'isAdmin': false,
        'totalOrders': 0,
        'fcmToken': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserModel(uid: uid, email: email, isAdmin: false);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account already exists with this email.');
        case 'invalid-email':
          throw Exception('Please enter a valid email address.');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection.');
        default:
          throw Exception('Signup failed: ${e.message}');
      }
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw Exception('Login failed. Please try again.');
      }
      final uid = user.uid;

      // CRITICAL: always fetch isAdmin from Firestore after login
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('User profile not found. Please contact support.');
      }

      return UserModel.fromMap(uid, doc.data()!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'network-request-failed':
          throw Exception('No internet connection.');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    }
  }

  Future<UserModel?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(user.uid, doc.data()!);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

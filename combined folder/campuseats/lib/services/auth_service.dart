import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserModel> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    // Create user document in Firestore
    await _db.collection('users').doc(uid).set({
      'email': email,
      'isAdmin': false,
      'totalOrders': 0,
      'fcmToken': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return UserModel(uid: uid, email: email, isAdmin: false);
  }

  Future<UserModel> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    // CRITICAL: always fetch isAdmin from Firestore after login
    // Never trust client-side state for role checks
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found. Please contact support.');
    }

    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if a user is already logged in on app start
  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserModel?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(user.uid, doc.data()!);
  }
}

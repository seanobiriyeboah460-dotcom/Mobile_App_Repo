import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(user?.email?.substring(0, 1).toUpperCase() ?? 'U'),
            ),
            SizedBox(height: 16),
            Text(user?.email ?? 'No email'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authVm.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

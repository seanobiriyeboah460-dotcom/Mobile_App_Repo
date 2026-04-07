import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import 'notes_list_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    setState(() => _isBiometricSupported = canCheck);
    if (canCheck) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NotesListScreen()),
      );
    }
  }

  Future<void> _verifyPin() async {
    final storedHash = await SecureStorageService.loadPinHash();
    if (storedHash == null) {
      // First time setup – create PIN
      _setupPin();
      return;
    }
    final inputHash = sha256
        .convert(utf8.encode(_pinController.text))
        .toString();
    if (inputHash == storedHash) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NotesListScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Wrong PIN')));
    }
  }

  void _setupPin() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set PIN'),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Enter 4-6 digit PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final hash = sha256
                  .convert(utf8.encode(_pinController.text))
                  .toString();
              await SecureStorageService.savePinHash(hash);
              Navigator.pop(context);
              _verifyPin();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isBiometricSupported) ...[
              ElevatedButton.icon(
                onPressed: _authenticateWithBiometrics,
                icon: Icon(Icons.fingerprint),
                label: Text('Unlock with Biometrics'),
              ),
              SizedBox(height: 20),
              Text('OR'),
            ],
            SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Enter PIN'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPin,
              child: Text('Unlock with PIN'),
            ),
          ],
        ),
      ),
    );
  }
}

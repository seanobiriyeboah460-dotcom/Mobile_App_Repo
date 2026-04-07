import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import 'notes_list_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  bool _biometricAttempted = false;
  bool _isBiometricAvailable = false;
  String? _biometricError;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    if (!mounted) return;
    setState(() => _isBiometricAvailable = available);
    if (available) {
      await _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final authenticated = await _biometricService.authenticate();
    if (!mounted) return;
    setState(() {
      _biometricAttempted = true;
      _biometricError =
          authenticated ? null : 'Biometric unlock failed. Please try again.';
    });
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
    final inputHash =
        sha256.convert(utf8.encode(_pinController.text)).toString();
    if (inputHash == storedHash) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NotesListScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN')),
      );
    }
  }

  void _setupPin() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter 4-6 digit PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final hash =
                  sha256.convert(utf8.encode(_pinController.text)).toString();
              await SecureStorageService.savePinHash(hash);
              Navigator.pop(context);
              _verifyPin();
            },
            child: const Text('Save'),
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
            if (_isBiometricAvailable) ...[
              ElevatedButton.icon(
                onPressed: _authenticateWithBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock with Biometrics'),
              ),
              const SizedBox(height: 20),
              if (_biometricAttempted && _biometricError != null) ...[
                Text(
                  _biometricError!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
              ],
            ] else ...[
              TextField(
                controller: _pinController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Enter PIN'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                child: const Text('Unlock with PIN'),
              ),
            ],
            if (!_isBiometricAvailable) const SizedBox(height: 20),
            if (!_isBiometricAvailable)
              const Text(
                'Biometric authentication is not available. Please unlock with PIN.',
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    return await _localAuth.canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }

  Future<bool> isBiometricAvailable() async {
    final canCheck = await canCheckBiometrics();
    if (!canCheck) return false;
    final available = await getAvailableBiometrics();
    return available.isNotEmpty;
  }

  Future<bool> authenticate() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock your notes',
      );
      return authenticated;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}

import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    return await _localAuth.canCheckBiometrics;
  }

  Future<bool> authenticate() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock your notes',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    final canCheck = await canCheckBiometrics();
    print('Can check biometrics: $canCheck');
    if (!canCheck) return false;
    final available = await getAvailableBiometrics();
    print('Available biometrics: $available');
    return available.isNotEmpty;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }
}

import 'package:local_auth/local_auth.dart';

/// Fingerprint / Face ID. Every failure (no sensor, none enrolled, cancelled,
/// wrong finger) is reported as `false` so the caller falls back to OTP.
class BiometricAuth {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
          localizedReason: reason, biometricOnly: true);
    } catch (_) {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The registered account and the login session, saved on the phone.
/// shortcut: one account per phone and no server, so the number is only
/// checked against the account registered on this device. Replace with real
/// accounts when the backend exists.
class AccountStore extends ChangeNotifier {
  static final instance = AccountStore();

  String? name;
  String? phone; // null for an account made with Google
  String? email;
  bool loggedIn = false; // stays true until the user logs out
  bool biometricEnabled = false;
  bool biometricAsked = false; // the "turn on fingerprint?" offer was answered

  bool isRegistered(String number) => phone != null && phone == number;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      name = p.getString('acct_name');
      phone = p.getString('acct_phone');
      email = p.getString('acct_email');
      loggedIn = (phone != null || email != null) &&
          (p.getBool('acct_logged_in') ?? false);
      biometricEnabled = p.getBool('acct_biometric') ?? false;
      biometricAsked = p.getBool('acct_biometric_asked') ?? false;
    } catch (_) {} // nothing saved: start logged out
  }

  /// Creates the account and logs the user in.
  Future<void> register(
      {required String name, String? phone, required String email}) {
    this.name = name;
    this.phone = phone;
    this.email = email;
    loggedIn = true;
    biometricEnabled = false;
    biometricAsked = false;
    return _save();
  }

  /// Google account chosen: log in if it is already this account, else create it.
  /// shortcut: one account per device, so a different Google account replaces
  /// the old one (and its phone number); fix with real accounts on a backend.
  Future<void> signInWithGoogle({required String name, required String email}) {
    if (this.email == email) return logIn();
    return register(name: name, email: email);
  }

  Future<void> logIn() {
    loggedIn = true;
    return _save();
  }

  Future<void> logOut() {
    loggedIn = false;
    return _save();
  }

  /// Records the answer to the "turn on fingerprint / Face ID?" offer.
  Future<void> setBiometric(bool enabled) {
    biometricEnabled = enabled;
    biometricAsked = true;
    return _save();
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      for (final e in {
        'acct_name': name,
        'acct_phone': phone,
        'acct_email': email,
      }.entries) {
        e.value == null ? await p.remove(e.key) : await p.setString(e.key, e.value!);
      }
      await p.setBool('acct_logged_in', loggedIn);
      await p.setBool('acct_biometric', biometricEnabled);
      await p.setBool('acct_biometric_asked', biometricAsked);
    } catch (_) {} // not saving is fine: the session still works until the app closes
  }
}

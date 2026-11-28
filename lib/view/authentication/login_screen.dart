import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/model/phone.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/repository/biometric_auth.dart';
import 'package:sajilyatra/repository/google_auth.dart';
import 'package:sajilyatra/view/authentication/widgets/otp_step.dart';
import 'package:sajilyatra/view/home.dart';

/// Passwordless login: an OTP sent to the registered number, or fingerprint /
/// Face ID once the user has turned it on. A failed fingerprint falls back to OTP.
class LoginScreen extends StatefulWidget {
  final BiometricAuth? biometric; // tests pass a fake one
  final GoogleAuth? googleAuth; // tests pass a fake one
  const LoginScreen({super.key, this.biometric, this.googleAuth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  late final _biometric = widget.biometric ?? BiometricAuth();
  final _account = AccountStore.instance;

  bool _otpSent = false;
  bool _bioAvailable = false;
  String? _error; // a key into the translation table

  @override
  void initState() {
    super.initState();
    _biometric.isAvailable().then((ok) {
      if (mounted) setState(() => _bioAvailable = ok);
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String get _number => _phone.text.trim();

  void _sendOtp() {
    if (!isNepaliMobile(_number)) {
      return setState(() => _error = 'Enter a valid mobile number (starts with 98 or 97)');
    }
    if (!_account.isRegistered(_number)) {
      return setState(
          () => _error = 'This number is not registered. Sign up first.');
    }
    setState(() {
      _otpSent = true;
      _error = null;
    });
  }

  Future<void> _loggedIn() async {
    await _account.logIn();
    await _offerBiometric();
    if (mounted) goHome(context);
  }

  /// After the first login, offer fingerprint / Face ID if the phone has it.
  Future<void> _offerBiometric() async {
    if (!_bioAvailable || _account.biometricEnabled || _account.biometricAsked) {
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Faster login next time?')),
        content: Text(context.tr(
            'Turn on fingerprint / Face ID to log in without waiting for a code.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('Not now'))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('Enable'))),
        ],
      ),
    );
    if (!mounted) return;
    // Check once that it works before turning it on.
    final works = yes == true &&
        await _biometric.authenticate(
            context.tr('Confirm your fingerprint or face to log in'));
    await _account.setBiometric(works);
  }

  Future<void> _loginWithGoogle() async {
    try {
      final google = await (widget.googleAuth ?? GoogleAuth()).signIn();
      if (google == null || !mounted) return; // the user closed the page
      await _account.signInWithGoogle(name: google.name, email: google.email);
      if (mounted) goHome(context);
    } catch (e) {
      debugPrint('Google sign-in failed: $e'); // the real reason, for the debug console
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr('Google sign-in did not work. Try again.'))));
    }
  }

  Future<void> _loginWithBiometric() async {
    final reason = context.tr('Confirm your fingerprint or face to log in');
    if (await _biometric.authenticate(reason)) {
      await _account.logIn();
      if (mounted) goHome(context);
      return;
    }
    // Failed or cancelled: fall back to an OTP for the registered number.
    if (!mounted) return;
    _phone.text = _account.phone ?? '';
    setState(() {
      _otpSent = true;
      _error = 'Fingerprint did not work. Log in with an OTP instead.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kText,
        elevation: 0,
        actions: const [LanguageToggle()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('Sign in'),
                  style: const TextStyle(
                      color: kText, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(context.tr('Welcome back'),
                  style: const TextStyle(color: kMuted, fontSize: 16)),
              const SizedBox(height: 28),
              if (_otpSent)
                OtpStep(
                  phone: _number,
                  message: _error, // the fingerprint fallback notice, if any
                  onVerified: _loggedIn,
                  onChangeNumber: () => setState(() {
                    _otpSent = false;
                    _error = null;
                  }),
                )
              else ...[
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  decoration: InputDecoration(
                    hintText: context.tr('Phone number'),
                    hintStyle: const TextStyle(color: kMuted),
                    counterText: '',
                    filled: true,
                    fillColor: kCard,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: kBorder, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: kViolet, width: 2),
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(context.tr(_error!),
                        style: TextStyle(color: Colors.red.shade700)),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: kOnAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(context.tr('Send OTP'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(context.tr('Continue with Google')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kText,
                      side: const BorderSide(color: kBorder, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
                if (_bioAvailable && _account.biometricEnabled) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _loginWithBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(
                          context.tr('Log in with fingerprint / Face ID')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kText,
                        side: const BorderSide(color: kBorder, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Text.rich(
                    TextSpan(
                      text: context.tr("Don't have an account? "),
                      style: const TextStyle(color: kMuted),
                      children: [
                        TextSpan(
                            text: context.tr('Sign up'),
                            style: const TextStyle(
                                color: kViolet, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

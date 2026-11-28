import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/model/phone.dart';
import 'package:sajilyatra/model/profile.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/repository/google_auth.dart';
import 'package:sajilyatra/repository/profile_store.dart';
import 'package:sajilyatra/view/authentication/login_screen.dart';
import 'package:sajilyatra/view/authentication/widgets/otp_step.dart';
import 'package:sajilyatra/view/home.dart';
import 'package:sajilyatra/view/profile/id_verification_screen.dart';
import 'package:sajilyatra/view/shift/shift_screen.dart';
import 'package:sajilyatra/view/tracking/live_tracking_screen.dart';

/// Sign up with a name and a mobile number; the account is only created once
/// the OTP sent to that number is entered (US 1.1). No password to remember.
class RegisterScreen extends StatefulWidget {
  final String role;
  final GoogleAuth? googleAuth; // tests pass a fake one
  const RegisterScreen({super.key, required this.role, this.googleAuth});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _verifying = false; // true = waiting for the OTP

  @override
  void dispose() {
    for (final c in [_name, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kMuted),
      floatingLabelStyle: const TextStyle(color: kViolet),
      prefixIcon: Icon(icon, color: kMuted),
      counterText: '',
      filled: true,
      fillColor: kCard,
      enabledBorder: border(kBorder),
      focusedBorder: border(kViolet, 2),
      errorBorder: border(Colors.red.shade700),
      focusedErrorBorder: border(Colors.red.shade700, 2),
    );
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) setState(() => _verifying = true);
  }

  /// The right OTP was entered: now the account is created.
  Future<void> _createAccount() async {
    // TODO: send to backend once available.
    await AccountStore.instance.register(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim());
    await _finish(_name.text.trim());
  }

  /// "Continue with Google": the account is created from the Google profile.
  Future<void> _googleSignUp() async {
    try {
      final google = await (widget.googleAuth ?? GoogleAuth()).signIn();
      if (google == null || !mounted) return; // the user closed the page
      await AccountStore.instance
          .signInWithGoogle(name: google.name, email: google.email);
      await _finish(google.name);
    } catch (e) {
      debugPrint('Google sign-in failed: $e'); // the real reason, for the debug console
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr('Google sign-in did not work. Try again.'))));
    }
  }

  /// The account exists: remember the profile type and move on.
  Future<void> _finish(String name) async {
    await ProfileStore.instance.setRole(widget.role);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kViolet,
        content: Text(context.tr('Welcome aboard, {}!', [name]),
            style: const TextStyle(color: Colors.white)),
      ),
    );
    if (rolesNeedingId.contains(widget.role)) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const IdVerificationScreen()));
    } else {
      goHome(context);
    }
  }

  void _appleSignUp() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.tr('Apple sign-up is not available yet.'))));

  Widget _socialButton(String label, IconData icon, VoidCallback onPressed) =>
      Expanded(
        child: OutlinedButton.icon(
          // TODO: Apple needs an Apple developer account and Firebase's Apple provider.
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: kText,
            side: const BorderSide(color: kBorder, width: 1.5),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      );

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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset('assets/images/sajil_logo.png', height: 120),
              ),
              const SizedBox(height: 16),
              Text(context.tr('Create account'),
                  style: const TextStyle(
                      color: kText, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kViolet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    context.tr('Registering as {}', [context.tr(widget.role)]),
                    style: const TextStyle(
                        color: kViolet, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
              if (_verifying) ...[
                Text(
                    context.tr(
                        'Enter the code sent to {}', [_phone.text.trim()]),
                    style: const TextStyle(color: kMuted)),
                const SizedBox(height: 12),
                OtpStep(
                  phone: _phone.text.trim(),
                  onVerified: _createAccount,
                  onChangeNumber: () => setState(() => _verifying = false),
                ),
              ] else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _name,
                        style: const TextStyle(color: kText),
                        cursorColor: kViolet,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                            context.tr('Full name'), Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? context.tr('Enter your name')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        style: const TextStyle(color: kText),
                        cursorColor: kViolet,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                            context.tr('Email'), Icons.email_outlined),
                        validator: (v) =>
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(v?.trim() ?? '')
                                ? null
                                : context.tr('Enter a valid email'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phone,
                        style: const TextStyle(color: kText),
                        cursorColor: kViolet,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 10,
                        decoration: _decoration(
                            context.tr('Phone number'), Icons.phone_outlined),
                        validator: (v) => isNepaliMobile(v ?? '')
                            ? null
                            : context.tr(
                                'Enter a valid mobile number (starts with 98 or 97)'),
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _socialButton(context.tr('Google'),
                              Icons.g_mobiledata, _googleSignUp),
                          const SizedBox(width: 8),
                          _socialButton(
                              context.tr('Apple'), Icons.apple, _appleSignUp),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          // TODO: drivers will need a real account; guests only get the map.
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    widget.role == 'Conductor / Driver'
                                        ? const ShiftScreen()
                                        : const LiveTrackingScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kText,
                            side: const BorderSide(color: kBorder, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                          ),
                          child: Text(context.tr('Continue as guest'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: context.tr('Already have an account? '),
                      style: const TextStyle(color: kMuted),
                      children: [
                        TextSpan(
                            text: context.tr('Log in'),
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

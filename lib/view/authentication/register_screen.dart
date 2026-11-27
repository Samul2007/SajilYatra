import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/view/authentication/login_screen.dart';
import 'package:sajilyatra/view/shift/shift_screen.dart';
import 'package:sajilyatra/view/tracking/live_tracking_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kMuted),
      floatingLabelStyle: const TextStyle(color: kViolet),
      prefixIcon: Icon(icon, color: kMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: kCard,
      enabledBorder: border(kBorder),
      focusedBorder: border(kViolet, 2),
      errorBorder: border(Colors.red.shade700),
      focusedErrorBorder: border(Colors.red.shade700, 2),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: send to backend once available.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kViolet,
        content: Text('Welcome aboard, ${_name.text.trim()}!', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kText,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/images/sajil_logo.png', height: 120),
                ),
                const SizedBox(height: 16),
                const Text('Create account',
                    style: TextStyle(
                        color: kText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kViolet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Registering as ${widget.role}',
                      style: const TextStyle(
                          color: kViolet, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Full name', Icons.person_outline),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Email', Icons.email_outlined),
                  validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(v?.trim() ?? '')
                      ? null
                      : 'Enter a valid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Phone number', Icons.phone_outlined),
                  // Nepal mobile numbers: 10 digits.
                  validator: (v) => RegExp(r'^\d{10}$').hasMatch(v?.trim() ?? '')
                      ? null
                      : 'Enter a 10-digit phone number',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'Password',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: kMuted),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (v) =>
                      (v ?? '').length < 6 ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirm,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  obscureText: _hidePassword,
                  decoration:
                      _decoration('Confirm password', Icons.lock_outline),
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: kOnAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Register',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
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
                          builder: (_) => widget.role == 'Conductor / Driver'
                              ? const ShiftScreen()
                              : const LiveTrackingScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kText,
                      side: const BorderSide(color: kBorder, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Continue as guest',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: kMuted),
                        children: [
                          TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                  color: kViolet,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

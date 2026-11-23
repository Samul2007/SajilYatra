import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/view/tracking/live_tracking_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: kCard,
      enabledBorder: border(kBorder),
      focusedBorder: border(kViolet, 2),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 2),
    );
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: authenticate against the backend; for now go straight to the map.
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const LiveTrackingScreen()));
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sign in',
                    style: TextStyle(
                        color: kText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Welcome back',
                    style: TextStyle(color: kMuted, fontSize: 16)),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  decoration: _decoration('abc@gmail.com'),
                  validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(v?.trim() ?? '')
                      ? null
                      : 'Enter a valid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _hidePassword,
                  style: const TextStyle(color: kText),
                  cursorColor: kViolet,
                  decoration: _decoration(
                    'Password',
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
                      (v ?? '').isEmpty ? 'Enter your password' : null,
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Forgot password?',
                      style: TextStyle(color: kViolet)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: kOnAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Login',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: kMuted),
                        children: [
                          TextSpan(
                              text: 'Sign up',
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/repository/otp_service.dart';

/// "Enter the code we sent you": sends a code to [phone] when it appears, and
/// calls [onVerified] once the right code is entered. Used by login and register.
class OtpStep extends StatefulWidget {
  final String phone;
  final Future<void> Function() onVerified;
  final VoidCallback onChangeNumber;
  final String? message; // a translation key shown as a notice, e.g. fingerprint fallback

  const OtpStep({
    super.key,
    required this.phone,
    required this.onVerified,
    required this.onChangeNumber,
    this.message,
  });

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
  final _otp = TextEditingController();
  final _service = OtpService.instance;

  String? _demoCode; // shown as a "demo SMS" because there is no SMS gateway
  String? _error; // a key into the translation table
  int _wait = 0; // seconds until "Resend code" works
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _sendCode() {
    _timer?.cancel();
    setState(() {
      _demoCode = _service.send(widget.phone);
      _error = null;
      _otp.clear();
      _wait = _service.resendWaitSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _wait = _service.resendWaitSeconds);
    });
  }

  Future<void> _verify() async {
    final result = _service.verify(widget.phone, _otp.text.trim());
    if (result == OtpResult.ok) return widget.onVerified();
    setState(() => _error = switch (result) {
          OtpResult.wrong => 'Wrong code. Try again.',
          OtpResult.expired => 'This code has expired. Request a new one.',
          _ => 'Request a new code.',
        });
  }

  @override
  Widget build(BuildContext context) {
    final notice = _error ?? widget.message;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCardActive,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kAccent, width: 1.5),
          ),
          child: Text(
              context.tr(
                  'Demo SMS: your Sajil Yatra code is {} (valid for 5 minutes)',
                  [_demoCode ?? '']),
              style:
                  const TextStyle(color: kText, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otp,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          style: const TextStyle(color: kText, letterSpacing: 6),
          cursorColor: kViolet,
          decoration: InputDecoration(
            hintText: context.tr('Enter the 6-digit code'),
            hintStyle: const TextStyle(color: kMuted, letterSpacing: 0),
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
        if (notice != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(context.tr(notice),
                style: TextStyle(color: Colors.red.shade700)),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _verify,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: kOnAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
            ),
            child: Text(context.tr('Verify'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: widget.onChangeNumber,
              child: Text(context.tr('Change number')),
            ),
            _wait > 0
                ? Text(context.tr('Resend code in {}s', [_wait]),
                    style: const TextStyle(color: kMuted))
                : TextButton(
                    onPressed: _sendCode,
                    child: Text(context.tr('Resend code'))),
          ],
        ),
      ],
    );
  }
}

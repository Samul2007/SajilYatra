import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sajilyatra/repository/otp_service.dart';

void main() {
  late DateTime now;
  late OtpService otp;

  setUp(() {
    now = DateTime(2026, 11, 27, 10);
    otp = OtpService(clock: () => now, random: Random(1));
  });

  test('sends a 6-digit code that works once', () {
    final code = otp.send('9801234567');
    expect(code, matches(RegExp(r'^\d{6}$')));
    expect(otp.verify('9801234567', code), OtpResult.ok);
    expect(otp.verify('9801234567', code), OtpResult.none); // used up
  });

  test('a wrong code is rejected and the right one still works', () {
    final code = otp.send('9801234567');
    final wrong = code == '000000' ? '111111' : '000000';
    expect(otp.verify('9801234567', wrong), OtpResult.wrong);
    expect(otp.verify('9801234567', code), OtpResult.ok);
  });

  test('a code only works for the number it was sent to', () {
    final code = otp.send('9801234567');
    expect(otp.verify('9811111111', code), OtpResult.none);
  });

  test('the code expires after 5 minutes', () {
    final code = otp.send('9801234567');
    now = now.add(const Duration(minutes: 5, seconds: 1));
    expect(otp.verify('9801234567', code), OtpResult.expired);
  });

  test('resend is blocked for 60 seconds', () {
    expect(otp.resendWaitSeconds, 0);
    otp.send('9801234567');
    expect(otp.resendWaitSeconds, greaterThan(0));
    now = now.add(const Duration(seconds: 61));
    expect(otp.resendWaitSeconds, 0);
  });

  test('too many wrong guesses need a new code', () {
    final code = otp.send('9801234567');
    final wrong = code == '000000' ? '111111' : '000000';
    for (var i = 0; i < OtpService.maxAttempts; i++) {
      expect(otp.verify('9801234567', wrong), OtpResult.wrong);
    }
    expect(otp.verify('9801234567', code), OtpResult.none);
  });
}

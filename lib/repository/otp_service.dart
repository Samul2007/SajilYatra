import 'dart:math';

enum OtpResult { ok, wrong, expired, none }

/// One-time codes for passwordless login. shortcut: there is no SMS gateway,
/// so [send] hands the code back and the screen shows it as a "demo SMS".
/// Replace [send] with a real SMS call (NTC / Ncell) when the backend exists.
class OtpService {
  OtpService({DateTime Function()? clock, Random? random})
      : _now = clock ?? DateTime.now,
        _random = random ?? Random.secure();

  static final instance = OtpService();

  static const validFor = Duration(minutes: 5);
  static const resendAfter = Duration(seconds: 60);
  static const maxAttempts = 5;

  final DateTime Function() _now;
  final Random _random;

  String? _phone;
  String? _code;
  DateTime? _sentAt;
  int _attempts = 0;

  /// Makes a new 6-digit code for [phone] and returns it.
  String send(String phone) {
    _phone = phone;
    _code = _random.nextInt(1000000).toString().padLeft(6, '0');
    _sentAt = _now();
    _attempts = 0;
    return _code!;
  }

  /// Seconds until a new code may be requested (0 = now).
  int get resendWaitSeconds {
    if (_sentAt == null) return 0;
    final left = resendAfter - _now().difference(_sentAt!);
    return left.isNegative ? 0 : left.inSeconds + 1;
  }

  OtpResult verify(String phone, String code) {
    if (_code == null || _phone != phone || _attempts >= maxAttempts) {
      return OtpResult.none;
    }
    if (_now().isAfter(_sentAt!.add(validFor))) {
      _code = null;
      return OtpResult.expired;
    }
    _attempts++;
    if (code != _code) return OtpResult.wrong;
    _code = null; // a code works once
    return OtpResult.ok;
  }
}

import 'dart:async';

import 'package:flutter/services.dart';

/// The Android side of the panic alert (MainActivity.kt): volume-button
/// presses and sending a text message without opening the messages app.
/// Every call quietly reports "no" where there is no Android (tests, desktop).
class PanicChannel {
  PanicChannel._() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'volumeKey') _volumeKeys.add(null);
    });
  }

  /// There is one Android connection; everyone shares it.
  static final instance = PanicChannel._();

  /// For tests: a channel that does not listen to Android.
  PanicChannel.fake();

  static const _channel = MethodChannel('sajilyatra/panic');
  final _volumeKeys = StreamController<void>.broadcast();

  /// One event per volume-button press (only while the app is open).
  Stream<void> get volumeKeys => _volumeKeys.stream;

  Future<bool> hasSmsPermission() => _bool('hasSmsPermission');

  /// Asks for the "send SMS" permission. Do this when the user switches a
  /// trigger on, not during an emergency.
  Future<bool> requestSmsPermission() => _bool('requestSmsPermission');

  Future<bool> sendSms(List<String> numbers, String body) =>
      _bool('sendSms', {'numbers': numbers, 'body': body});

  Future<bool> _bool(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<bool>(method, args) ?? false;
    } catch (_) {
      return false;
    }
  }
}

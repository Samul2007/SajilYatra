import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/repository/emergency_contacts_store.dart';
import 'package:sajilyatra/repository/panic_channel.dart';
import 'package:sajilyatra/repository/panic_detectors.dart';
import 'package:sajilyatra/repository/panic_settings.dart';
import 'package:sajilyatra/repository/sos_service.dart';

/// Lets the panic alert show a message from outside any screen.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Watches the phone for the panic gestures the user switched on (a hard
/// shake, or two volume presses) and then quietly sends the SOS message.
///
/// shortcut: this only works while the app is open. Android does not deliver
/// volume presses or sensor readings to an app in the background unless it
/// runs a foreground service, which is not built yet (US 2.2 asks for it).
class PanicService {
  PanicService({
    PanicSettings? settings,
    PanicChannel? channel,
    SosService? sos,
    EmergencyContactsStore? contacts,
    this.shakeMagnitudes,
    DateTime Function()? clock,
    this.cooldown = const Duration(seconds: 30),
  })  : settings = settings ?? PanicSettings.instance,
        _channel = channel ?? PanicChannel.instance,
        _sos = sos ?? SosService(),
        _contacts = contacts ?? EmergencyContactsStore.instance,
        _now = clock ?? DateTime.now;

  static final instance = PanicService();

  final PanicSettings settings;
  final PanicChannel _channel;
  final SosService _sos;
  final EmergencyContactsStore _contacts;
  final Stream<double>? shakeMagnitudes; // tests pass their own readings
  final DateTime Function() _now;
  final Duration cooldown;

  final _shake = ShakeDetector();
  final _doublePress = DoublePressDetector();
  StreamSubscription<double>? _shakeSub;
  StreamSubscription<void>? _volumeSub;
  DateTime? _lastAlert;

  /// How many alerts have been sent (the settings screen and tests watch it).
  final alerts = ValueNotifier<int>(0);

  /// Start listening; call once when the app starts.
  void start() {
    settings.addListener(_apply);
    _apply();
  }

  void _apply() {
    if (settings.shake && _shakeSub == null) {
      final stream = shakeMagnitudes ??
          userAccelerometerEventStream().map((e) => sqrt(e.x * e.x + e.y * e.y + e.z * e.z));
      _shakeSub = stream.listen((m) {
        if (_shake.add(m, _now())) fire();
      });
    } else if (!settings.shake) {
      _shakeSub?.cancel();
      _shakeSub = null;
    }
    if (settings.volume && _volumeSub == null) {
      _volumeSub = _channel.volumeKeys.listen((_) {
        if (_doublePress.press(_now())) fire();
      });
    } else if (!settings.volume) {
      _volumeSub?.cancel();
      _volumeSub = null;
    }
  }

  /// Sends the alert. Ignored for [cooldown] after the last one, so a long
  /// shake or a nervous thumb does not text everyone ten times.
  Future<void> fire() async {
    final last = _lastAlert;
    if (last != null && _now().difference(last) < cooldown) return;
    _lastAlert = _now();

    HapticFeedback.heavyImpact(); // a buzz you can feel, nothing on screen
    final contacts = List.of(_contacts.contacts);
    if (contacts.isNotEmpty) {
      await _sos.trigger(
        contacts: contacts,
        name: AccountStore.instance.name ?? 'A Sajil Yatra user',
        silent: true,
      );
      alerts.value++;
    }
    if (!settings.silent) {
      rootMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(trNow(contacts.isEmpty
            ? 'Add an emergency contact so the panic alert has someone to reach.'
            : 'Panic alert sent to your emergency contacts.')),
      ));
    }
  }

  void dispose() {
    settings.removeListener(_apply);
    _shakeSub?.cancel();
    _volumeSub?.cancel();
  }
}

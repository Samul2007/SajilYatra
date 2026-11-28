import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/repository/emergency_contacts_store.dart';
import 'package:sajilyatra/repository/panic_channel.dart';
import 'package:sajilyatra/repository/panic_detectors.dart';
import 'package:sajilyatra/repository/panic_service.dart';
import 'package:sajilyatra/repository/panic_settings.dart';
import 'package:sajilyatra/repository/sos_service.dart';

class FakeChannel extends PanicChannel {
  FakeChannel() : super.fake();
  final presses = StreamController<void>.broadcast();
  @override
  Stream<void> get volumeKeys => presses.stream;
}

class RecordingSos extends SosService {
  RecordingSos() : super(channel: PanicChannel.fake());
  final calls = <({List<EmergencyContact> contacts, bool silent})>[];

  @override
  Future<SosOutcome> trigger({
    required List<EmergencyContact> contacts,
    required String name,
    bool silent = false,
  }) async {
    calls.add((contacts: contacts, silent: silent));
    return SosOutcome(contacts, true, const LatLng(27.69, 85.31));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShakeDetector', () {
    final t0 = DateTime(2026, 11, 27, 12);
    DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

    test('three hard jolts in a row count as a shake', () {
      final d = ShakeDetector();
      expect(d.add(20, at(0)), isFalse);
      expect(d.add(20, at(300)), isFalse);
      expect(d.add(20, at(600)), isTrue);
    });

    test('gentle movement (walking) never triggers', () {
      final d = ShakeDetector();
      for (var i = 0; i < 20; i++) {
        expect(d.add(9, at(i * 300)), isFalse);
      }
    });

    test('jolts spread over too long do not count', () {
      final d = ShakeDetector();
      expect(d.add(20, at(0)), isFalse);
      expect(d.add(20, at(1000)), isFalse);
      expect(d.add(20, at(2000)), isFalse); // the first one is now too old
    });

    test('one shake that makes several quick readings counts once', () {
      final d = ShakeDetector();
      expect(d.add(20, at(0)), isFalse);
      expect(d.add(20, at(50)), isFalse);
      expect(d.add(20, at(100)), isFalse);
      expect(d.add(20, at(120)), isFalse);
    });

    test('a lower threshold is more sensitive', () {
      final d = ShakeDetector(threshold: 8);
      expect(d.add(9, at(0)), isFalse);
      expect(d.add(9, at(300)), isFalse);
      expect(d.add(9, at(600)), isTrue);
    });
  });

  group('DoublePressDetector', () {
    final t0 = DateTime(2026, 11, 27, 12);

    test('two quick presses trigger, a single press does not', () {
      final d = DoublePressDetector();
      expect(d.press(t0), isFalse);
      expect(d.press(t0.add(const Duration(milliseconds: 400))), isTrue);
    });

    test('slow presses do not trigger, and a trigger starts afresh', () {
      final d = DoublePressDetector();
      expect(d.press(t0), isFalse);
      expect(d.press(t0.add(const Duration(seconds: 2))), isFalse);
      expect(d.press(t0.add(const Duration(milliseconds: 2300))), isTrue);
      expect(d.press(t0.add(const Duration(milliseconds: 2400))), isFalse);
    });
  });

  group('PanicService', () {
    late PanicSettings settings;
    late FakeChannel channel;
    late RecordingSos sos;
    late EmergencyContactsStore contacts;
    late StreamController<double> shakes;
    late DateTime now;
    late PanicService panic;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      settings = PanicSettings();
      channel = FakeChannel();
      sos = RecordingSos();
      contacts = EmergencyContactsStore()
        ..contacts.add(const EmergencyContact('Mum', '9841111111'));
      shakes = StreamController<double>.broadcast();
      now = DateTime(2026, 11, 27, 12);
      panic = PanicService(
        settings: settings,
        channel: channel,
        sos: sos,
        contacts: contacts,
        shakeMagnitudes: shakes.stream,
        clock: () => now,
      )..start();
    });

    tearDown(() => panic.dispose());

    Future<void> shake() async {
      for (var i = 0; i < 3; i++) {
        shakes.add(20);
        now = now.add(const Duration(milliseconds: 300));
        await pumpEventQueue();
      }
    }

    Future<void> pressVolumeTwice() async {
      channel.presses.add(null);
      await pumpEventQueue();
      now = now.add(const Duration(milliseconds: 300));
      channel.presses.add(null);
      await pumpEventQueue();
    }

    test('everything is off to begin with', () async {
      await shake();
      await pressVolumeTwice();
      expect(sos.calls, isEmpty);
    });

    test('a shake sends the alert silently to the saved contacts', () async {
      await settings.setShake(true);
      await shake();
      expect(sos.calls.length, 1);
      expect(sos.calls.single.silent, isTrue);
      expect(sos.calls.single.contacts.single.name, 'Mum');
    });

    test('a double volume press sends it too, a single press does not', () async {
      await settings.setVolume(true);
      channel.presses.add(null);
      await pumpEventQueue();
      expect(sos.calls, isEmpty);

      now = now.add(const Duration(milliseconds: 300));
      channel.presses.add(null);
      await pumpEventQueue();
      expect(sos.calls.length, 1);
    });

    test('each trigger can be turned off on its own', () async {
      await settings.setShake(true);
      await settings.setVolume(true);
      await settings.setShake(false);

      await shake();
      expect(sos.calls, isEmpty);
      await pressVolumeTwice();
      expect(sos.calls.length, 1);
    });

    test('a second alert within 30 seconds is ignored', () async {
      await settings.setShake(true);
      await shake();
      await shake();
      expect(sos.calls.length, 1);

      now = now.add(const Duration(seconds: 31));
      await shake();
      expect(sos.calls.length, 2);
    });

    test('with no saved contacts nothing is sent', () async {
      contacts.contacts.clear();
      await settings.setShake(true);
      await shake();
      expect(sos.calls, isEmpty);
    });
  });

  test('settings start off, silent is on, and the choices are saved', () async {
    SharedPreferences.setMockInitialValues({});
    final a = PanicSettings();
    expect([a.shake, a.volume, a.silent], [false, false, true]);

    await a.setShake(true);
    await a.setSilent(false);
    final b = PanicSettings();
    await b.load();
    expect([b.shake, b.volume, b.silent], [true, false, false]);
  });
}

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/repository/emergency_contacts_store.dart';
import 'package:sajilyatra/repository/panic_channel.dart';
import 'package:url_launcher/url_launcher.dart';

class SosOutcome {
  final List<EmergencyContact> contacts; // who the message was prepared for
  final bool smsOpened; // the messages app opened with the text filled in
  final LatLng? position; // null = no GPS fix
  const SosOutcome(this.contacts, this.smsOpened, this.position);
}

String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String mapLink(LatLng p) =>
    'https://maps.google.com/?q=${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}';

/// The text sent to the contacts. The map link is added after translating so
/// its digits stay ASCII (a link with Nepali numerals would not open).
String sosMessage({required String name, required DateTime time, LatLng? position}) {
  final who = trNow(name);
  if (position == null) {
    return trNow(
        'SOS! {} needs help. Location not available (sent from Sajil Yatra at {})',
        [who, hhmm(time)]);
  }
  return trNow(
          'SOS! {} needs help. Location: {} (sent from Sajil Yatra at {})',
          [who, '{LINK}', hhmm(time)])
      .replaceFirst('{LINK}', mapLink(position));
}

/// Finds the position and opens the messages app. shortcut: there is no
/// server, so the "live link" is a map link for the position at this moment
/// and the user must press Send; a backend could push a live link instead.
class SosService {
  SosService({PanicChannel? channel})
      : _channel = channel ?? PanicChannel.instance;

  static const policeNumber = '100';
  final PanicChannel _channel;

  /// [prompt] false = never show a permission dialog (silent panic alert).
  Future<LatLng?> currentPosition({bool prompt = true}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && prompt) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      return LatLng(p.latitude, p.longitude);
    } catch (_) {
      // No fix in time: use the last one the phone remembers, if any.
      try {
        final p = await Geolocator.getLastKnownPosition();
        return p == null ? null : LatLng(p.latitude, p.longitude);
      } catch (_) {
        return null;
      }
    }
  }

  Future<bool> openSms(List<String> numbers, String body) async {
    try {
      return await launchUrl(Uri.parse(
          'sms:${numbers.join(',')}?body=${Uri.encodeComponent(body)}'));
    } catch (_) {
      return false;
    }
  }

  Future<bool> callPolice() async {
    try {
      return await launchUrl(Uri.parse('tel:$policeNumber'));
    } catch (_) {
      return false;
    }
  }

  Future<SosOutcome> trigger({
    required List<EmergencyContact> contacts,
    required String name,
    bool silent = false, // true = send the text without opening any screen
  }) async {
    final position = await currentPosition(prompt: !silent);
    var opened = false;
    if (contacts.isNotEmpty) {
      final numbers = [for (final c in contacts) c.phone];
      final body = sosMessage(name: name, time: DateTime.now(), position: position);
      // Silent: send directly. If the phone refuses (no SMS permission), open
      // the messages app instead so the alert is not lost.
      opened = silent && await _channel.sendSms(numbers, body);
      if (!opened) opened = await openSms(numbers, body);
    }
    return SosOutcome(List.of(contacts), opened, position);
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContact {
  final String name;
  final String phone;
  const EmergencyContact(this.name, this.phone);
}

/// Up to [maxContacts] people who get the SOS message. Saved on the phone.
/// shortcut: local only; sync to the user's account once there is a backend.
class EmergencyContactsStore extends ChangeNotifier {
  static final instance = EmergencyContactsStore();
  static const maxContacts = 3;
  static const _key = 'emergency_contacts';

  final contacts = <EmergencyContact>[];

  bool get isFull => contacts.length >= maxContacts;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw == null) return;
      contacts
        ..clear()
        ..addAll([
          for (final m in jsonDecode(raw) as List)
            EmergencyContact(m['name'] as String, m['phone'] as String),
        ]);
    } catch (_) {} // unreadable data: start with no contacts
  }

  /// False when the list is full or the number is already saved.
  Future<bool> add(String name, String phone) async {
    if (isFull || contacts.any((c) => c.phone == phone)) return false;
    contacts.add(EmergencyContact(name, phone));
    await _save();
    return true;
  }

  Future<void> remove(EmergencyContact contact) async {
    contacts.remove(contact);
    await _save();
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _key,
          jsonEncode([
            for (final c in contacts) {'name': c.name, 'phone': c.phone},
          ]));
    } catch (_) {} // not saving is fine: the list still works this session
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/model/profile.dart';

/// The user's profile type, ID photo and verification status, saved on the
/// phone. shortcut: nothing is sent anywhere, so nobody can really review the
/// ID; swap [submitId] and [review] for backend calls (story 8.4 admin).
class ProfileStore extends ChangeNotifier {
  static final instance = ProfileStore();

  String role = 'Commuter';
  String? idPhotoPath; // shortcut: the picker's temp path, copy it to app storage with a backend
  VerificationStatus status = VerificationStatus.notSubmitted;

  bool get needsId => rolesNeedingId.contains(role);

  /// Commuters can use everything at once; the other profiles only once verified.
  bool get isUnlocked => !needsId || status == VerificationStatus.verified;

  bool get isVerifiedConductor =>
      role == 'Conductor / Driver' && status == VerificationStatus.verified;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final savedRole = p.getString('profile_role');
      if (savedRole != null && profileRoles.contains(savedRole)) role = savedRole;
      idPhotoPath = p.getString('profile_id_path');
      status = VerificationStatus.values.firstWhere(
        (s) => s.name == p.getString('profile_id_status'),
        orElse: () => VerificationStatus.notSubmitted,
      );
    } catch (_) {} // nothing saved: stay a Commuter
  }

  /// Choosing another profile type clears the previous ID.
  Future<void> setRole(String newRole) async {
    if (newRole == role) return;
    role = newRole;
    idPhotoPath = null;
    status = VerificationStatus.notSubmitted;
    await _save();
  }

  Future<void> submitId(String path) async {
    if (!needsId) return;
    idPhotoPath = path;
    status = VerificationStatus.pending;
    await _save();
  }

  /// Stand-in for the reviewer's decision (only reachable from a debug build).
  Future<void> review({required bool approved}) async {
    if (status != VerificationStatus.pending) return;
    status = approved ? VerificationStatus.verified : VerificationStatus.rejected;
    await _save();
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('profile_role', role);
      await p.setString('profile_id_status', status.name);
      if (idPhotoPath == null) {
        await p.remove('profile_id_path');
      } else {
        await p.setString('profile_id_path', idPhotoPath!);
      }
    } catch (_) {} // not saving is fine: the choice still applies this session
  }
}

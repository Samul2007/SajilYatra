import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/model/profile.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/view/safety/emergency_contacts_screen.dart';
import 'package:sajilyatra/view/safety/panic_settings_screen.dart';
import 'package:sajilyatra/repository/google_auth.dart';
import 'package:sajilyatra/repository/profile_store.dart';
import 'package:sajilyatra/view/authentication/login_screen.dart';

/// Choose a profile type and upload an ID photo (US 1.3).
class IdVerificationScreen extends StatelessWidget {
  const IdVerificationScreen({super.key});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final store = ProfileStore.instance;
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.tr('Could not open the photo picker.');
    try {
      final file = await ImagePicker()
          .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
      if (file != null) await store.submitId(file.path);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kText,
        elevation: 0,
        title: Text(context.tr('My profile'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: const [LanguageToggle()],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ProfileStore.instance,
          builder: (context, _) {
            final store = ProfileStore.instance;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(context.tr('Profile type'),
                    style: const TextStyle(
                        color: kText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in profileRoles)
                      ChoiceChip(
                        label: Text(context.tr(r)),
                        selected: store.role == r,
                        onSelected: (_) => store.setRole(r),
                        selectedColor: kAccent,
                        backgroundColor: kCard,
                        labelStyle: const TextStyle(color: kText),
                        side: const BorderSide(color: kBorder),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (!store.needsId)
                  Text(
                      context.tr(
                          'Commuters do not need an ID. Everything is unlocked.'),
                      style: const TextStyle(color: kMuted))
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(context.tr('ID photo'),
                            style: const TextStyle(
                                color: kText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                      _StatusChip(store.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_message(context, store.status),
                      style: const TextStyle(color: kMuted)),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: store.idPhotoPath == null
                        ? const Icon(Icons.badge_outlined,
                            size: 48, color: kMuted)
                        : Image.file(File(store.idPhotoPath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: kMuted)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(context, ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text(context.tr('Take photo')),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: kText,
                              side: const BorderSide(color: kBorder, width: 1.5),
                              minimumSize: const Size.fromHeight(48)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(context, ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(context.tr('Choose photo')),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: kText,
                              side: const BorderSide(color: kBorder, width: 1.5),
                              minimumSize: const Size.fromHeight(48)),
                        ),
                      ),
                    ],
                  ),
                  // No admin exists yet (story 8.4), so debug builds can play the reviewer.
                  if (kDebugMode &&
                      store.status == VerificationStatus.pending) ...[
                    const SizedBox(height: 24),
                    const Text('Demo only (debug build): act as the reviewer',
                        style: TextStyle(color: kMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => store.review(approved: true),
                            child: const Text('Approve'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => store.review(approved: false),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmergencyContactsScreen())),
                  icon: const Icon(Icons.contact_phone_outlined),
                  label: Text(context.tr('Emergency contacts')),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: kText,
                      side: const BorderSide(color: kBorder, width: 1.5),
                      minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PanicSettingsScreen())),
                  icon: const Icon(Icons.vibration),
                  label: Text(context.tr('Panic alert')),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: kText,
                      side: const BorderSide(color: kBorder, width: 1.5),
                      minimumSize: const Size.fromHeight(48)),
                ),
                if (AccountStore.instance.loggedIn) ...[
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await AccountStore.instance.logOut();
                      await GoogleAuth().signOut();
                      nav.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (_) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(context.tr('Log out')),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: kText,
                        side: const BorderSide(color: kBorder, width: 1.5),
                        minimumSize: const Size.fromHeight(48)),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _message(BuildContext context, VerificationStatus s) => switch (s) {
        VerificationStatus.notSubmitted => context.tr(
            'Upload a clear photo of your ID to unlock features for this profile.'),
        VerificationStatus.pending => context.tr(
            'Your ID is being reviewed. Features for this profile unlock once it is verified.'),
        VerificationStatus.verified =>
          context.tr('Your ID is verified. All features for this profile are unlocked.'),
        VerificationStatus.rejected =>
          context.tr('Your ID was rejected. Upload a clearer photo.'),
      };
}

class _StatusChip extends StatelessWidget {
  final VerificationStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      VerificationStatus.notSubmitted => (kCard, kMuted, Icons.upload_file),
      VerificationStatus.pending => (kAccent, kText, Icons.hourglass_top),
      VerificationStatus.verified => (kViolet, Colors.white, Icons.verified),
      VerificationStatus.rejected =>
        (Colors.red.shade700, Colors.white, Icons.error_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(context.tr(status.label),
              style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

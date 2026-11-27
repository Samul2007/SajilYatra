import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/repository/panic_channel.dart';
import 'package:sajilyatra/repository/panic_settings.dart';

/// Turn each panic trigger on or off (US 2.2).
class PanicSettingsScreen extends StatelessWidget {
  const PanicSettingsScreen({super.key});

  /// Sending texts without opening any screen needs the SMS permission; ask
  /// now, while the user is calm, not during an emergency.
  Future<void> _askSmsPermission(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final note = context.tr(
        'Without the SMS permission the alert opens your messages app instead of sending silently.');
    if (!await PanicChannel.instance.requestSmsPermission()) {
      messenger.showSnackBar(SnackBar(content: Text(note)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = PanicSettings.instance;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kText,
        elevation: 0,
        title: Text(context.tr('Panic alert'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: const [LanguageToggle()],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: s,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                  context.tr(
                      'Send your SOS message to your emergency contacts without anyone noticing.'),
                  style: const TextStyle(color: kMuted)),
              const SizedBox(height: 12),
              SwitchListTile(
                value: s.shake,
                activeThumbColor: kViolet,
                title: Text(context.tr('Shake the phone hard 3 times')),
                onChanged: (on) {
                  s.setShake(on);
                  if (on) _askSmsPermission(context);
                },
              ),
              SwitchListTile(
                value: s.volume,
                activeThumbColor: kViolet,
                title: Text(context.tr('Press a volume button twice')),
                onChanged: (on) {
                  s.setVolume(on);
                  if (on) _askSmsPermission(context);
                },
              ),
              SwitchListTile(
                value: s.silent,
                activeThumbColor: kViolet,
                title: Text(context.tr('Silent mode')),
                subtitle: Text(context.tr(
                    'Nothing is shown on screen. You only feel a short buzz.')),
                onChanged: s.setSilent,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCardActive,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kAccent, width: 1.5),
                ),
                child: Text(
                    context.tr(
                        'These triggers work while Sajil Yatra is open on your phone. Working in the background is not built yet. Add emergency contacts first.'),
                    style: const TextStyle(color: kText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

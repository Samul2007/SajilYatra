import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/repository/emergency_contacts_store.dart';
import 'package:sajilyatra/repository/sos_service.dart';
import 'package:sajilyatra/view/safety/emergency_contacts_screen.dart';

const _sosRed = Color(0xFFD32F2F);

/// Always-visible SOS button (US 2.1). Tapping it starts a 3-second countdown
/// that can be cancelled; when it ends, the contacts' messages are prepared.
class SosButton extends StatelessWidget {
  final SosService? service; // tests pass a fake one
  const SosButton({super.key, this.service});

  Future<void> _start(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CountdownDialog(),
    );
    if (confirmed != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(color: kViolet),
          const SizedBox(width: 16),
          Expanded(child: Text(context.tr('Getting your location…'))),
        ]),
      ),
    );
    final sos = service ?? SosService();
    final outcome = await sos.trigger(
      contacts: EmergencyContactsStore.instance.contacts,
      name: AccountStore.instance.name ?? 'A Sajil Yatra user',
    );
    if (!context.mounted) return;
    Navigator.of(context).pop(); // the "getting your location" dialog
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg,
      builder: (_) => _Confirmation(outcome, sos),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'sos',
      backgroundColor: _sosRed,
      foregroundColor: Colors.white,
      tooltip: 'SOS',
      onPressed: () => _start(context),
      child: const Text('SOS',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  const _CountdownDialog();

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _left = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _left--);
      if (_left <= 0) {
        t.cancel();
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('SOS in {} seconds', [_left]),
          style: const TextStyle(color: _sosRed, fontWeight: FontWeight.w800)),
      content: Text(context.tr('Press cancel if this was a mistake.')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.tr('Cancel'),
              style: const TextStyle(fontSize: 18, color: kText)),
        ),
      ],
    );
  }
}

/// Says exactly what happened, so nobody thinks help was sent when it was not.
class _Confirmation extends StatelessWidget {
  final SosOutcome outcome;
  final SosService service;
  const _Confirmation(this.outcome, this.service);

  @override
  Widget build(BuildContext context) {
    final p = outcome.position;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('SOS alert prepared'),
                style: const TextStyle(
                    color: _sosRed, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (outcome.contacts.isEmpty) ...[
              Text(context.tr(
                  'No emergency contacts saved. Add some so they get your location.')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmergencyContactsScreen()));
                },
                child: Text(context.tr('Add contact')),
              ),
            ] else ...[
              Text(context.tr('Messages opened: press Send in each one.'),
                  style: const TextStyle(color: kMuted)),
              const SizedBox(height: 6),
              for (final c in outcome.contacts)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                      outcome.smsOpened ? Icons.sms_outlined : Icons.error_outline,
                      color: outcome.smsOpened ? kViolet : _sosRed),
                  title: Text(context.tr(
                      outcome.smsOpened
                          ? '{} · message opened'
                          : '{} · could not open messages',
                      [c.name])),
                ),
            ],
            const Divider(),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_police_outlined, color: kViolet),
              title: Text(context.tr('Nepal Police (100)')),
              trailing: FilledButton(
                onPressed: service.callPolice,
                style: FilledButton.styleFrom(backgroundColor: _sosRed),
                child: Text(context.tr('Call')),
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.support_agent, color: kMuted),
              title: Text(context.tr('Transit dispatch: not connected yet'),
                  style: const TextStyle(color: kMuted)),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined, color: kMuted),
              title: Text(p == null
                  ? context.tr('Location not available')
                  : context.tr('Location: {}', [
                      '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}'
                    ])),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('Done')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

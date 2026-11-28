import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/model/phone.dart';
import 'package:sajilyatra/repository/emergency_contacts_store.dart';

/// The people who get your SOS message (up to 3).
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _store = EmergencyContactsStore.instance;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    await _store.add(_name.text.trim(), _phone.text.trim());
    _name.clear();
    _phone.clear();
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kMuted),
        floatingLabelStyle: const TextStyle(color: kViolet),
        counterText: '',
        filled: true,
        fillColor: kCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kViolet, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kText,
        elevation: 0,
        title: Text(context.tr('Emergency contacts'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: const [LanguageToggle()],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(context.tr('You can save up to 3 contacts.'),
                  style: const TextStyle(color: kMuted)),
              const SizedBox(height: 12),
              if (_store.contacts.isEmpty)
                Text(context.tr('No emergency contacts yet.')),
              for (final c in _store.contacts)
                Card(
                  color: kCard,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: kBorder, width: 1.5),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person_outline, color: kViolet),
                    title: Text(c.name),
                    subtitle: Text(context.tr(c.phone)),
                    trailing: IconButton(
                      tooltip: context.tr('Delete'),
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _store.remove(c),
                    ),
                  ),
                ),
              if (!_store.isFull) ...[
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        style: const TextStyle(color: kText),
                        cursorColor: kViolet,
                        decoration: _decoration(context.tr('Contact name')),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? context.tr('Enter your name')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        style: const TextStyle(color: kText),
                        cursorColor: kViolet,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 10,
                        decoration: _decoration(context.tr('Phone number')),
                        validator: (v) => isNepaliMobile(v ?? '')
                            ? null
                            : context.tr(
                                'Enter a valid mobile number (starts with 98 or 97)'),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _add,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                            foregroundColor: kOnAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                          ),
                          child: Text(context.tr('Add contact'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

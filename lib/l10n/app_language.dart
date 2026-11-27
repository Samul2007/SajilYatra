import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/l10n/ne_strings.dart';

/// The app language (English or Nepali). The choice is saved on the phone.
class AppLanguage extends ChangeNotifier {
  static final instance = AppLanguage();
  static const _prefsKey = 'language';

  bool isNepali = false;
  Locale get locale => Locale(isNepali ? 'ne' : 'en');

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isNepali = prefs.getString(_prefsKey) == 'ne';
    } catch (_) {} // no saved choice is fine: stay in English
  }

  Future<void> setNepali(bool value) async {
    if (isNepali == value) return;
    isNepali = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, value ? 'ne' : 'en');
    } catch (_) {} // not saving is fine: the choice still applies this session
  }
}

const _nepaliDigits = '०१२३४५६७८९';

String _translate(bool nepali, String en, List<Object> args) {
  var text = nepali ? (neStrings[en] ?? en) : en;
  for (final a in args) {
    text = text.replaceFirst('{}', '$a');
  }
  return nepali ? toNepaliDigits(text) : text;
}

String toNepaliDigits(String s) => s.replaceAllMapped(
    RegExp(r'[0-9]'), (m) => _nepaliDigits[int.parse(m[0]!)]);

/// Text without a BuildContext (error messages, notifications).
String trNow(String en, [List<Object> args = const []]) =>
    _translate(AppLanguage.instance.isNepali, en, args);

extension AppText on BuildContext {
  /// Translates [en]; each `{}` in it is replaced by the next of [args].
  /// Reading the locale here makes the widget rebuild when the language changes.
  String tr(String en, [List<Object> args = const []]) =>
      _translate(Localizations.localeOf(this).languageCode == 'ne', en, args);
}

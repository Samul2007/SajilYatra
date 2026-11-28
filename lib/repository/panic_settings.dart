import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which panic triggers are on, saved on the phone. Everything starts off.
class PanicSettings extends ChangeNotifier {
  static final instance = PanicSettings();

  bool shake = false; // shake the phone hard 3 times
  bool volume = false; // press a volume button twice
  bool silent = true; // no alert on screen when a trigger fires

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      shake = p.getBool('panic_shake') ?? false;
      volume = p.getBool('panic_volume') ?? false;
      silent = p.getBool('panic_silent') ?? true;
    } catch (_) {} // nothing saved: everything stays off
  }

  Future<void> setShake(bool on) => _set(() => shake = on);
  Future<void> setVolume(bool on) => _set(() => volume = on);
  Future<void> setSilent(bool on) => _set(() => silent = on);

  Future<void> _set(VoidCallback change) async {
    change();
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('panic_shake', shake);
      await p.setBool('panic_volume', volume);
      await p.setBool('panic_silent', silent);
    } catch (_) {} // not saving is fine: the choice still applies this session
  }
}

/// Recognises a vigorous shake: [shakesNeeded] hard jolts within [window].
/// Feed it the phone's acceleration (gravity removed, in m/s²).
class ShakeDetector {
  ShakeDetector({
    this.threshold = 15, // sensitivity: walking stays well under 10
    this.shakesNeeded = 3,
    this.window = const Duration(milliseconds: 1500),
    this.minGap = const Duration(milliseconds: 150),
  });

  final double threshold;
  final int shakesNeeded;
  final Duration window;
  final Duration minGap; // one physical shake makes several readings; count it once
  final _hits = <DateTime>[];

  /// True when this reading completes a shake.
  bool add(double magnitude, DateTime now) {
    if (magnitude < threshold) return false;
    if (_hits.isNotEmpty && now.difference(_hits.last) < minGap) return false;
    _hits.add(now);
    _hits.removeWhere((t) => now.difference(t) > window);
    if (_hits.length < shakesNeeded) return false;
    _hits.clear();
    return true;
  }
}

/// Recognises two volume-button presses in quick succession.
class DoublePressDetector {
  DoublePressDetector({this.window = const Duration(milliseconds: 800)});

  final Duration window;
  DateTime? _last;

  /// True when this press is the second of a double press.
  bool press(DateTime now) {
    final last = _last;
    if (last != null && now.difference(last) <= window) {
      _last = null;
      return true;
    }
    _last = now;
    return false;
  }
}

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/model/shift.dart';

abstract class ShiftRepository {
  /// Makes sure GPS is on and permitted. Returns an error message, or null if OK.
  Future<String?> prepare();

  /// Live positions of this phone. On Android keeps running in the
  /// background through a foreground notification.
  Stream<BroadcastPoint> watchPoints();

  /// Sends one position to passengers.
  void broadcast(Shift shift, BroadcastPoint point);
}

/// Real phone GPS. The broadcast only stores points in memory because there is
/// no backend yet; swap [broadcast] for an API / Firebase call later.
class GeolocatorShiftRepository implements ShiftRepository {
  final List<BroadcastPoint> sent = [];

  @override
  Future<String?> prepare() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Turn on location (GPS) to start your shift.';
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Allow location access to start your shift.';
    }
    return null;
  }

  @override
  Stream<BroadcastPoint> watchPoints() {
    const common = LocationAccuracy.high;
    final settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: common,
            distanceFilter: 10,
            intervalDuration: const Duration(seconds: 5),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'Sajil Yatra shift active',
              notificationText: 'Your vehicle location is being shared.',
              enableWakeLock: true,
            ),
          )
        : const LocationSettings(accuracy: common, distanceFilter: 10);
    return Geolocator.getPositionStream(locationSettings: settings).map(
      (p) => BroadcastPoint(
        LatLng(p.latitude, p.longitude),
        p.speed * 3.6, // m/s to km/h
        p.timestamp,
      ),
    );
  }

  @override
  void broadcast(Shift shift, BroadcastPoint point) => sent.add(point);
}

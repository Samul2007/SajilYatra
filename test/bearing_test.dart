import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/vehicle_status.dart';
import 'package:sajilyatra/viewmodel/live_tracking_viewmodel.dart';

VehicleStatus at(double lat, double lng, double speed) => VehicleStatus(
      position: LatLng(lat, lng),
      speedKmh: speed,
      headingDeg: 0,
      nextStop: const Stop('X', LatLng(0, 0)),
      thenStops: const [],
      etaMinutes: 1,
      updatedAt: DateTime(2026),
    );

void main() {
  test('bearing follows consecutive positions', () {
    final east = nextBearing(at(27.69, 85.30, 20), at(27.69, 85.31, 20), null);
    final north = nextBearing(at(27.69, 85.30, 20), at(27.70, 85.30, 20), null);
    expect(east, closeTo(90, 1));
    expect(north, closeTo(0, 1));
  });

  test('stationary vehicle has no arrow', () {
    expect(nextBearing(at(27.69, 85.30, 20), at(27.69, 85.30, 0), 90), isNull);
  });

  test('tiny GPS jitter keeps the last direction', () {
    final b = nextBearing(at(27.69, 85.30, 20), at(27.690001, 85.30, 20), 123);
    expect(b, 123);
  });

  test('first update has no direction yet', () {
    expect(nextBearing(null, at(27.69, 85.30, 20), null), isNull);
  });
}

import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/vehicle_status.dart';

/// Fake bus that drives along [BusRoute.stops] forever, pausing at each stop.
/// Replace with a real (Firebase / API) repository exposing the same
/// `watch` method when a backend exists.
class SimulatedVehicleRepository {
  /// [tick] is the real time between updates; each tick advances the bus by
  /// [tick] * [timeScale] of simulated driving so the demo is watchable.
  SimulatedVehicleRepository({
    this.tick = const Duration(seconds: 1),
    this.timeScale = 10,
  });

  final Duration tick;
  final double timeScale;
  static const _distance = Distance();

  Stream<VehicleStatus> watch(BusRoute route) async* {
    final pts = route.stops.map((s) => s.position).toList();
    final cum = <double>[0]; // metres from the start to each stop
    for (var i = 1; i < pts.length; i++) {
      cum.add(cum.last + _distance(pts[i - 1], pts[i]));
    }

    final dt = tick.inMilliseconds / 1000 * timeScale;
    var traveled = 0.0;
    var next = 1; // index of the next stop
    var dwell = 0; // ticks left standing at a stop
    var t = 0;

    while (true) {
      var speed = 0.0;
      if (dwell > 0) {
        dwell--;
      } else {
        speed = 18 + 8 * sin(t / 6); // 10..26 km/h
        traveled += speed / 3.6 * dt;
        if (traveled >= cum[next]) {
          traveled = cum[next];
          if (next == pts.length - 1) {
            traveled = 0; // end of line: start over
            next = 1;
          } else {
            next++;
          }
          dwell = 3;
        }
      }
      t++;

      final seg = next - 1;
      final frac = (traveled - cum[seg]) / (cum[next] - cum[seg]);
      final a = pts[seg], b = pts[next];
      final remainingKm = (cum[next] - traveled) / 1000;

      yield VehicleStatus(
        position: LatLng(
          a.latitude + (b.latitude - a.latitude) * frac,
          a.longitude + (b.longitude - a.longitude) * frac,
        ),
        speedKmh: speed,
        headingDeg: (_distance.bearing(a, b) + 360) % 360,
        nextStop: route.stops[next],
        thenStops: route.stops.skip(next + 1).take(3).toList(),
        etaMinutes: (remainingKm / max(speed, 12) * 60).ceil(),
        updatedAt: DateTime.now(),
      );
      await Future.delayed(tick);
    }
  }
}

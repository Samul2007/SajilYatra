import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/vehicle_status.dart';
import 'package:sajilyatra/repository/vehicle_repository.dart';

const _distance = Distance();

/// Direction of travel in degrees (0 = north, clockwise), worked out from two
/// consecutive positions. Returns null while the vehicle is stationary, so the
/// map shows no arrow. Moves under 1 m (GPS jitter) keep the last direction.
double? nextBearing(VehicleStatus? previous, VehicleStatus now, double? last) {
  if (now.isStanding) return null;
  if (previous == null) return last;
  if (_distance(previous.position, now.position) < 1) return last;
  return (_distance.bearing(previous.position, now.position) + 360) % 360;
}

class LiveTrackingViewModel extends ChangeNotifier {
  LiveTrackingViewModel({
    required this.route,
    SimulatedVehicleRepository? repository,
  }) {
    _sub = (repository ?? SimulatedVehicleRepository()).watch(route).listen(
      (s) {
        bearing = nextBearing(status, s, bearing);
        status = s;
        notifyListeners();
      },
    );
  }

  final BusRoute route;
  VehicleStatus? status; // null until the first update arrives
  double? bearing; // null = stationary, no arrow
  late final StreamSubscription<VehicleStatus> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

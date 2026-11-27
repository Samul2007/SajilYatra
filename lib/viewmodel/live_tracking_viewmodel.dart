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
    List<BusRoute>? routes,
    SimulatedVehicleRepository? repository,
  }) : routes = routes ?? BusRoute.all {
    final repo = repository ?? SimulatedVehicleRepository();
    for (final r in this.routes) {
      _subs.add(repo.watch(r).listen((s) {
        bearings[r] = nextBearing(statuses[r], s, bearings[r]);
        statuses[r] = s;
        notifyListeners();
      }));
    }
  }

  final List<BusRoute> routes;
  final statuses = <BusRoute, VehicleStatus>{}; // latest position per vehicle
  final bearings = <BusRoute, double?>{}; // null = stationary, no arrow
  final hiddenTypes = <VehicleType>{}; // filtered out by the user
  final _subs = <StreamSubscription<VehicleStatus>>[];

  /// The vehicle the camera is locked onto (US 4.4); null = free camera.
  BusRoute? selected;

  bool isVisible(BusRoute r) => !hiddenTypes.contains(r.type);

  void select(BusRoute r) {
    selected = r;
    notifyListeners();
  }

  void release() {
    if (selected == null) return;
    selected = null;
    notifyListeners();
  }

  void toggleType(VehicleType t) {
    if (!hiddenTypes.remove(t)) hiddenTypes.add(t);
    if (selected != null && !isVisible(selected!)) selected = null;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

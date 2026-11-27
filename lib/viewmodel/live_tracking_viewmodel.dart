import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/vehicle_status.dart';
import 'package:sajilyatra/repository/vehicle_repository.dart';

class LiveTrackingViewModel extends ChangeNotifier {
  LiveTrackingViewModel({
    required this.route,
    SimulatedVehicleRepository? repository,
  }) {
    _sub = (repository ?? SimulatedVehicleRepository()).watch(route).listen(
      (s) {
        status = s;
        notifyListeners();
      },
    );
  }

  final BusRoute route;
  VehicleStatus? status; // null until the first update arrives
  late final StreamSubscription<VehicleStatus> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

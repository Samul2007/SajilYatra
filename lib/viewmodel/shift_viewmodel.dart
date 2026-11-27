import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/shift.dart';
import 'package:sajilyatra/repository/shift_repository.dart';

class ShiftViewModel extends ChangeNotifier {
  ShiftViewModel({ShiftRepository? repository, this.isVerified = true})
      : _repository = repository ?? GeolocatorShiftRepository();

  final ShiftRepository _repository;

  // TODO: set from the real ID verification (story 1.3) once it exists.
  final bool isVerified;

  BusRoute route = BusRoute.all.first;
  Vehicle vehicle = Vehicle.all.first;

  Shift? shift; // non-null while a shift is running
  BroadcastPoint? lastPoint;
  int broadcastCount = 0;
  String? error;
  StreamSubscription<BroadcastPoint>? _sub;

  bool get isActive => shift != null;

  void selectRoute(BusRoute r) {
    if (isActive) return;
    route = r;
    notifyListeners();
  }

  void selectVehicle(Vehicle v) {
    if (isActive) return;
    vehicle = v;
    notifyListeners();
  }

  Future<void> start() async {
    if (isActive) return;
    error = null;
    if (!isVerified) {
      error = 'Only verified conductors can start a shift.';
      return notifyListeners();
    }
    error = await _repository.prepare();
    if (error != null) return notifyListeners();

    final s = Shift(route, vehicle, DateTime.now());
    shift = s;
    broadcastCount = 0;
    lastPoint = null;
    _sub = _repository.watchPoints().listen(
      (p) {
        _repository.broadcast(s, p);
        lastPoint = p;
        broadcastCount++;
        notifyListeners();
      },
      onError: (_) {
        error = 'Lost the GPS signal. Check that location is on.';
        notifyListeners();
      },
    );
    notifyListeners();
  }

  Future<void> end() async {
    await _sub?.cancel(); // stops broadcasting and the background notification
    _sub = null;
    shift = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

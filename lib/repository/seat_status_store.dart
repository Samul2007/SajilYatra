import 'package:flutter/foundation.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/seat_status.dart';

/// Seat status the conductor reports for each route, shared with the passenger
/// map inside this app. shortcut: in memory only, replace with a backend
/// write (e.g. Firestore) so other phones see it too.
class SeatStatusStore extends ChangeNotifier {
  static final instance = SeatStatusStore();

  final _byRoute = <BusRoute, SeatUpdate>{};

  SeatUpdate? of(BusRoute route) => _byRoute[route];

  void set(BusRoute route, SeatStatus status) {
    _byRoute[route] = SeatUpdate(status, DateTime.now());
    notifyListeners();
  }
}

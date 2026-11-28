import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/model/bus_route.dart';

class Vehicle {
  final String name;
  final String plate;
  const Vehicle(this.name, this.plate);

  static const all = [
    Vehicle('Micro 12', 'Ba 2 Kha 4471'),
    Vehicle('Micro 5', 'Ba 1 Kha 2210'),
    Vehicle('Safa Tempo 4', 'Ba 3 Cha 1187'),
  ];
}

/// One conductor shift: which route and vehicle are being driven.
class Shift {
  final BusRoute route;
  final Vehicle vehicle;
  final DateTime startedAt;
  const Shift(this.route, this.vehicle, this.startedAt);
}

/// One location report sent to passengers during a shift.
class BroadcastPoint {
  final LatLng position;
  final double speedKmh;
  final DateTime time;
  const BroadcastPoint(this.position, this.speedKmh, this.time);
}

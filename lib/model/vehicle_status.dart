import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/model/bus_route.dart';

class VehicleStatus {
  final LatLng position;
  final double speedKmh;
  final double headingDeg; // 0 = north, clockwise
  final Stop nextStop;
  final List<Stop> thenStops;
  final int etaMinutes;
  final DateTime updatedAt;

  const VehicleStatus({
    required this.position,
    required this.speedKmh,
    required this.headingDeg,
    required this.nextStop,
    required this.thenStops,
    required this.etaMinutes,
    required this.updatedAt,
  });

  bool get isStanding => speedKmh == 0;

  String get headingLabel {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((headingDeg + 22.5) % 360 ~/ 45)];
  }
}

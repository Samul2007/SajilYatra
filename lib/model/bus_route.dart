import 'package:latlong2/latlong.dart';

class Stop {
  final String name;
  final LatLng position;
  const Stop(this.name, this.position);
}

class BusRoute {
  final String vehicleName;
  final String from;
  final String to;
  final String plate;
  final String operator;
  final List<Stop> stops;

  const BusRoute({
    required this.vehicleName,
    required this.from,
    required this.to,
    required this.plate,
    required this.operator,
    required this.stops,
  });

  // shortcut: stop coordinates are approximate and joined by straight lines,
  // upgrade to real road geometry (OSRM / GeoJSON) when the backend exists.
  static const kalankiKoteshwor = BusRoute(
    vehicleName: 'Micro 12',
    from: 'Kalanki',
    to: 'Koteshwor',
    plate: 'Ba 2 Kha 4471',
    operator: 'Nepal Yatayat Samiti',
    stops: [
      Stop('Kalanki', LatLng(27.6935, 85.2812)),
      Stop('Kalimati', LatLng(27.6978, 85.2985)),
      Stop('Tripureshwor', LatLng(27.6944, 85.3139)),
      Stop('Thapathali', LatLng(27.6925, 85.3185)),
      Stop('Maitighar', LatLng(27.6945, 85.3235)),
      Stop('Baneshwor', LatLng(27.6893, 85.3425)),
      Stop('Koteshwor', LatLng(27.6788, 85.3495)),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/view/tracking/widgets/vehicle_sheet.dart';
import 'package:sajilyatra/viewmodel/live_tracking_viewmodel.dart';

class LiveTrackingScreen extends StatefulWidget {
  final bool showVehicleTypeLabels;

  const LiveTrackingScreen({super.key, this.showVehicleTypeLabels = true});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  static const _vehicleTypes = ['Microvan', 'Tempo', 'Public Bus'];
  final String _vehicleType = 'Microvan';
  final _route = BusRoute.kalankiKoteshwor;
  final _map = MapController();
  late final LiveTrackingViewModel _vm;

  IconData _vehicleIcon(String type) => switch (type) {
    'Microvan' => Icons.airport_shuttle,
    'Tempo' => Icons.electric_rickshaw,
    _ => Icons.directions_bus,
  };

  @override
  void initState() {
    super.initState();
    _vm = LiveTrackingViewModel(route: _route)..addListener(_followBus);
  }

  void _followBus() {
    final s = _vm.status;
    if (s != null) _map.move(s.position, _map.camera.zoom);
  }

  @override
  void dispose() {
    _vm.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = _route.stops.map((s) => s.position).toList();
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListenableBuilder(
                  listenable: _vm,
                  builder: (context, _) => FlutterMap(
                    mapController: _map,
                    options: MapOptions(
                      initialCenter: points.first,
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                        'com.example.sajilyatra.sajilyatra',
                      ),
                      PolylineLayer(polylines: [
                        Polyline(points: points, strokeWidth: 5, color: kViolet),
                      ]),
                      MarkerLayer(markers: [
                        for (final stop in _route.stops)
                          Marker(
                            point: stop.position,
                            width: 14,
                            height: 14,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kBg,
                                shape: BoxShape.circle,
                                border: Border.all(color: kViolet, width: 2),
                              ),
                            ),
                          ),
                        if (_vm.status != null)
                          Marker(
                            point: _vm.status!.position,
                            width: widget.showVehicleTypeLabels ? 132 : 38,
                            height: 42,
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: kAccent,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: kBg, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26, blurRadius: 5),
                                ],
                              ),
                              child: widget.showVehicleTypeLabels
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_vehicleIcon(_vehicleType),
                                      color: kText, size: 18),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      _vehicleType,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: kText,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : const Icon(Icons.directions_bus,
                                  color: kText, size: 20),
                            ),
                          ),
                        if (widget.showVehicleTypeLabels)
                          for (var i = 0; i < _vehicleTypes.length; i++)
                            Marker(
                              point: _route.stops[
                              (i * 2 + 1) % _route.stops.length]
                                  .position,
                              width: 132,
                              height: 42,
                              child:
                              _VehicleTypeMarker(type: _vehicleTypes[i]),
                            ),
                      ]),
                      const RichAttributionWidget(
                        alignment: AttributionAlignment.bottomLeft,
                        attributions: [
                          TextSourceAttribution('© OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: kBg.withValues(alpha: 0.85),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: kText),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kBg.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Following ${_route.vehicleName}',
                              style: const TextStyle(
                                  color: kViolet,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: _vm,
            builder: (context, _) =>
                VehicleSheet(route: _route, status: _vm.status),
          ),
        ],
      ),
    );
  }
}

class _VehicleTypeMarker extends StatelessWidget {
  final String type;

  const _VehicleTypeMarker({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'Microvan' => Icons.airport_shuttle,
      'Tempo' => Icons.electric_rickshaw,
      _ => Icons.directions_bus,
    };

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBg, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kText, size: 18),
          const SizedBox(width: 5),
          Text(type,
              style: const TextStyle(
                  color: kText, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
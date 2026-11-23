import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/view/tracking/widgets/vehicle_sheet.dart';
import 'package:sajilyatra/viewmodel/live_tracking_viewmodel.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final _route = BusRoute.kalankiKoteshwor;
  final _map = MapController();
  late final LiveTrackingViewModel _vm;

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
                        // Official OpenStreetMap tiles (needs the User-Agent below; fine for a demo, not heavy traffic).
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.sajilyatra.sajilyatra',
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
                            width: 34,
                            height: 34,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: kAccent, shape: BoxShape.circle),
                              child: const Text('M',
                                  style: TextStyle(
                                      color: kText,
                                      fontWeight: FontWeight.w800)),
                            ),
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
                            icon: const Icon(Icons.arrow_back,
                                color: kText),
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

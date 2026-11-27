import 'dart:math';

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
  bool _expanded = false; // true = map fills the whole screen

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
                            width: 72,
                            height: 72,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_vm.bearing != null)
                                  Transform.rotate(
                                    angle: _vm.bearing! * pi / 180,
                                    // Dark arrow with a white outline so it stands out on any map colour.
                                    child: const Align(
                                      alignment: Alignment.topCenter,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(Icons.navigation,
                                              size: 32, color: Colors.white),
                                          Icon(Icons.navigation,
                                              size: 24, color: kText),
                                        ],
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: 34,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: kAccent, shape: BoxShape.circle),
                                  child: const Text('M',
                                      style: TextStyle(
                                          color: kText,
                                          fontWeight: FontWeight.w800)),
                                ),
                              ],
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
                Positioned(
                  right: 12,
                  bottom: 28,
                  child: FloatingActionButton.small(
                    heroTag: 'expand-map',
                    backgroundColor: kAccent,
                    foregroundColor: kOnAccent,
                    tooltip: _expanded ? 'Show details' : 'Full-screen map',
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Icon(
                        _expanded ? Icons.fullscreen_exit : Icons.fullscreen),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _expanded
                ? const SizedBox(width: double.infinity)
                : ListenableBuilder(
                    listenable: _vm,
                    builder: (context, _) =>
                        VehicleSheet(route: _route, status: _vm.status),
                  ),
          ),
        ],
      ),
    );
  }
}

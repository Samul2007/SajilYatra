import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sajilyatra/view/safety/sos_button.dart';
import 'package:sajilyatra/view/profile/id_verification_screen.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/repository/seat_status_store.dart';
import 'package:sajilyatra/view/tracking/widgets/vehicle_legend.dart';
import 'package:sajilyatra/view/tracking/widgets/vehicle_marker.dart';
import 'package:sajilyatra/view/tracking/widgets/vehicle_sheet.dart';
import 'package:sajilyatra/viewmodel/live_tracking_viewmodel.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final _map = MapController();
  late final LiveTrackingViewModel _vm;
  bool _expanded = false; // true = map fills the whole screen

  @override
  void initState() {
    super.initState();
    _vm = LiveTrackingViewModel()..addListener(_followSelected);
  }

  // US 4.4: while a vehicle is selected the camera stays on it.
  void _followSelected() {
    final r = _vm.selected;
    final s = r == null ? null : _vm.statuses[r];
    if (s != null) _map.move(s.position, _map.camera.zoom);
  }

  void _select(BusRoute r) {
    _vm.select(r);
    final s = _vm.statuses[r];
    if (s != null) _map.move(s.position, max(_map.camera.zoom, 14));
  }

  @override
  void dispose() {
    _vm.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListenableBuilder(
                  listenable: _vm,
                  builder: (context, _) => _buildMap(),
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
                        Row(children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kBg.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const LanguageToggle(),
                        ),
                        const SizedBox(width: 8),
                        ListenableBuilder(
                          listenable: _vm,
                          builder: (context, _) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: kBg.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                                _vm.selected == null
                                    ? context.tr('Tap a vehicle to follow it')
                                    : context.tr('Following {}',
                                        [context.tr(_vm.selected!.vehicleName)]),
                                style: const TextStyle(
                                    color: kViolet,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const Positioned(left: 12, bottom: 28, child: SosButton()),
                Positioned(
                  right: 12,
                  bottom: 76,
                  child: FloatingActionButton.small(
                    heroTag: 'profile',
                    backgroundColor: kBg,
                    foregroundColor: kText,
                    tooltip: context.tr('My profile'),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const IdVerificationScreen())),
                    child: const Icon(Icons.person_outline),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 28,
                  child: FloatingActionButton.small(
                    heroTag: 'expand-map',
                    backgroundColor: kAccent,
                    foregroundColor: kOnAccent,
                    tooltip: context.tr(_expanded ? 'Show details' : 'Full-screen map'),
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
                    listenable: Listenable.merge([_vm, SeatStatusStore.instance]),
                    builder: (context, _) {
                      final r = _vm.selected;
                      return r == null
                          ? VehicleLegend(vm: _vm)
                          : VehicleSheet(
                              route: r,
                              status: _vm.statuses[r],
                              seat: SeatStatusStore.instance.of(r),
                            );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final sel = _vm.selected;
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: const LatLng(27.6945, 85.3139),
        initialZoom: 13,
        // Panning or tapping the empty map releases the lock.
        onPositionChanged: (_, hasGesture) {
          if (hasGesture) _vm.release();
        },
        onTap: (_, _) => _vm.release(),
      ),
      children: [
        TileLayer(
          // Official OpenStreetMap tiles (needs the User-Agent below; fine for a demo, not heavy traffic).
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.sajilyatra.sajilyatra',
        ),
        if (sel != null)
          PolylineLayer(polylines: [
            Polyline(
              points: sel.stops.map((s) => s.position).toList(),
              strokeWidth: 5,
              color: kViolet,
            ),
          ]),
        MarkerLayer(markers: [
          if (sel != null)
            for (final stop in sel.stops)
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
          for (final r in _vm.routes)
            if (_vm.isVisible(r) && _vm.statuses[r] != null)
              Marker(
                point: _vm.statuses[r]!.position,
                width: 72,
                height: 72,
                child: GestureDetector(
                  onTap: () => _select(r),
                  child: VehicleMarker(
                    type: r.type,
                    bearing: _vm.bearings[r],
                    selected: r == sel,
                  ),
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
    );
  }
}

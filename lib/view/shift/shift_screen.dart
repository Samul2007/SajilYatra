import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/shift.dart';
import 'package:sajilyatra/viewmodel/shift_viewmodel.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final _vm = ShiftViewModel();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kMuted),
        floatingLabelStyle: const TextStyle(color: kViolet),
        filled: true,
        fillColor: kCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kViolet, width: 2),
        ),
      );

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final p = _vm.lastPoint;
        return PopScope(
          canPop: !_vm.isActive,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('End your shift before leaving.')),
              );
            }
          },
          child: Scaffold(
            backgroundColor: kBg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: kText,
              elevation: 0,
              title: const Text('Driver shift',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<BusRoute>(
                    initialValue: _vm.route,
                    decoration: _decoration('Route'),
                    items: [
                      for (final r in BusRoute.all)
                        DropdownMenuItem(
                            value: r, child: Text('${r.from} → ${r.to}')),
                    ],
                    onChanged: _vm.isActive ? null : (r) => _vm.selectRoute(r!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Vehicle>(
                    initialValue: _vm.vehicle,
                    decoration: _decoration('Vehicle'),
                    items: [
                      for (final v in Vehicle.all)
                        DropdownMenuItem(
                            value: v, child: Text('${v.name} · ${v.plate}')),
                    ],
                    onChanged:
                        _vm.isActive ? null : (v) => _vm.selectVehicle(v!),
                  ),
                  const SizedBox(height: 24),
                  if (_vm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(_vm.error!,
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                  if (_vm.isActive)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: kCardActive,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kAccent, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Shift is live',
                              style: TextStyle(
                                  color: kText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(
                              'Since ${_hhmm(_vm.shift!.startedAt)} · ${_vm.broadcastCount} updates sent',
                              style: const TextStyle(color: kMuted)),
                          const SizedBox(height: 6),
                          Text(
                              p == null
                                  ? 'Waiting for GPS…'
                                  : '${p.position.latitude.toStringAsFixed(5)}, ${p.position.longitude.toStringAsFixed(5)} · ${p.speedKmh.round()} km/h',
                              style: const TextStyle(color: kText)),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _vm.isActive ? _vm.end : _vm.start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _vm.isActive ? kText : kAccent,
                        foregroundColor: _vm.isActive ? Colors.white : kOnAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text(_vm.isActive ? 'End shift' : 'Start shift',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

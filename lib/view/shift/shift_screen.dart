import 'package:flutter/material.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/seat_status.dart';
import 'package:sajilyatra/model/shift.dart';
import 'package:sajilyatra/repository/profile_store.dart';
import 'package:sajilyatra/view/profile/id_verification_screen.dart';
import 'package:sajilyatra/repository/seat_status_store.dart';
import 'package:sajilyatra/viewmodel/shift_viewmodel.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  var _vm = ShiftViewModel(isVerified: ProfileStore.instance.isVerifiedConductor);

  Future<void> _openProfile() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const IdVerificationScreen()));
    if (!mounted) return;
    // A shift cannot be running here (it needs a verified conductor), so a fresh view model is safe.
    setState(() {
      _vm.dispose();
      _vm = ShiftViewModel(isVerified: ProfileStore.instance.isVerifiedConductor);
    });
  }

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
                SnackBar(content: Text(context.tr('End your shift before leaving.'))),
              );
            }
          },
          child: Scaffold(
            backgroundColor: kBg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: kText,
              elevation: 0,
        actions: const [LanguageToggle()],
              title: Text(context.tr('Driver shift'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (!_vm.isVerified)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: kCardActive,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kAccent, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              context.tr(
                                  'Only verified conductors can start a shift.'),
                              style: const TextStyle(
                                  color: kText, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                              context.tr(
                                  'Choose the Conductor / Driver profile and upload your ID to get verified.'),
                              style: const TextStyle(color: kMuted)),
                          TextButton(
                            onPressed: _openProfile,
                            child: Text(context.tr('Verify my ID')),
                          ),
                        ],
                      ),
                    ),
                  DropdownButtonFormField<BusRoute>(
                    initialValue: _vm.route,
                    decoration: _decoration(context.tr('Route')),
                    items: [
                      for (final r in BusRoute.all)
                        DropdownMenuItem(
                            value: r, child: Text('${context.tr(r.from)} → ${context.tr(r.to)}')),
                    ],
                    onChanged: _vm.isActive ? null : (r) => _vm.selectRoute(r!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Vehicle>(
                    initialValue: _vm.vehicle,
                    decoration: _decoration(context.tr('Vehicle')),
                    items: [
                      for (final v in Vehicle.all)
                        DropdownMenuItem(
                            value: v, child: Text('${context.tr(v.name)} · ${context.tr(v.plate)}')),
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
                          Text(context.tr('Shift is live'),
                              style: TextStyle(
                                  color: kText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(
                              context.tr('Since {} · {} updates sent', [_hhmm(_vm.shift!.startedAt), _vm.broadcastCount]),
                              style: const TextStyle(color: kMuted)),
                          const SizedBox(height: 6),
                          Text(
                              p == null
                                  ? context.tr('Waiting for GPS…')
                                  : '${p.position.latitude.toStringAsFixed(5)}, ${p.position.longitude.toStringAsFixed(5)} · ${context.tr('{} km/h', [p.speedKmh.round()])}',
                              style: const TextStyle(color: kText)),
                        ],
                      ),
                    ),
                  if (_vm.isActive)
                    ListenableBuilder(
                      listenable: SeatStatusStore.instance,
                      builder: (context, _) {
                        final current =
                            SeatStatusStore.instance.of(_vm.shift!.route)?.status;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('How full is the vehicle?'),
                                  style: TextStyle(
                                      color: kText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  for (final s in SeatStatus.values) ...[
                                    Expanded(
                                      child: SizedBox(
                                        height: 64,
                                        child: ElevatedButton(
                                          onPressed: () => SeatStatusStore
                                              .instance
                                              .set(_vm.shift!.route, s),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                current == s ? kAccent : kCard,
                                            foregroundColor: kText,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              side: BorderSide(
                                                color: current == s
                                                    ? kAccent
                                                    : kBorder,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          child: Text(context.tr(s.label),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                    ),
                                    if (s != SeatStatus.values.last)
                                      const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
                      child: Text(context.tr(_vm.isActive ? 'End shift' : 'Start shift'),
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

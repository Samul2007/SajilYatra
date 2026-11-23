import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/vehicle_status.dart';
import 'package:sajilyatra/view/tracking/widgets/stat_card.dart';

class VehicleSheet extends StatelessWidget {
  final BusRoute route;
  final VehicleStatus? status;

  const VehicleSheet({super.key, required this.route, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: kBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('M',
                      style: TextStyle(
                          color: kText,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${route.vehicleName} · ${route.from} → ${route.to}',
                          style: const TextStyle(
                              color: kText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text('${route.plate} · ${route.operator}',
                          style: const TextStyle(color: kMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (s == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(color: kViolet)),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                      child: StatCard(
                          icon: Icons.schedule,
                          value: '${s.etaMinutes} min',
                          caption: 'ETA to ${s.nextStop.name}')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          icon: Icons.speed,
                          value: '${s.speedKmh.round()} km/h',
                          caption: s.isStanding
                              ? 'Stopped'
                              : 'Moving, heading ${s.headingLabel}')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          icon: s.isStanding
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          value: s.isStanding ? 'At stop' : 'On the way',
                          caption: 'Updated just now')),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next: ${s.nextStop.name}',
                        style: const TextStyle(
                            color: kText,
                            fontWeight: FontWeight.w700)),
                    if (s.thenStops.isNotEmpty)
                      Text(
                          'Then ${s.thenStops.map((e) => e.name).join(' · ')}',
                          style: const TextStyle(color: kMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                // TODO: real boarding flow once tickets/payments exist.
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Boarding ${route.vehicleName}')),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: kOnAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Board this',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

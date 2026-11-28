import 'package:flutter/material.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/seat_status.dart';
import 'package:sajilyatra/model/vehicle_status.dart';
import 'package:sajilyatra/view/tracking/widgets/stat_card.dart';
import 'package:sajilyatra/view/tracking/widgets/vehicle_marker.dart';

class VehicleSheet extends StatelessWidget {
  final BusRoute route;
  final VehicleStatus? status;
  final SeatUpdate? seat; // reported by the conductor, null = not reported

  const VehicleSheet({
    super.key,
    required this.route,
    required this.status,
    this.seat,
  });

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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
                    color: styleOf(route.type).color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(styleOf(route.type).icon,
                      color: styleOf(route.type).onColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${context.tr(route.vehicleName)} · ${context.tr(route.from)} → ${context.tr(route.to)}',
                          style: const TextStyle(
                              color: kText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text(
                          '${context.tr(route.type.label)} · ${context.tr(route.plate)} · ${context.tr(route.operator)}',
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
                          value: context.tr('{} min', [s.etaMinutes]),
                          caption: context.tr('ETA to {}', [context.tr(s.nextStop.name)]))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          icon: Icons.speed,
                          value: context.tr('{} km/h', [s.speedKmh.round()]),
                          caption: s.isStanding
                              ? context.tr('Stopped')
                              : s.speedKmh < 5
                                  ? context.tr('Stuck in traffic')
                                  : context.tr('Moving, heading {}',
                                  [context.tr(s.headingLabel)]))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          icon: s.isStanding
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          value: context.tr(s.isStanding ? 'At stop' : 'On the way'),
                          caption: context.tr('Updated just now'))),
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
                    Text(context.tr('Next: {}', [context.tr(s.nextStop.name)]),
                        style: const TextStyle(
                            color: kText,
                            fontWeight: FontWeight.w700)),
                    if (s.thenStops.isNotEmpty)
                      Text(
                          context.tr('Then {}', [s.thenStops.map((e) => context.tr(e.name)).join(' · ')]),
                          style: const TextStyle(color: kMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                        seat == null
                            ? context.tr('Seats: not reported')
                            : context.tr('Seats: {} · updated {}', [context.tr(seat!.status.label), _hhmm(seat!.updatedAt)]),
                        style: const TextStyle(
                            color: kText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
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
                  SnackBar(content: Text(context.tr('Boarding {}', [context.tr(route.vehicleName)]))),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: kOnAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(context.tr('Board this'),
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

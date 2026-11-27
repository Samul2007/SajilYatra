import 'package:flutter/material.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/view/tracking/widgets/vehicle_marker.dart';
import 'package:sajilyatra/viewmodel/live_tracking_viewmodel.dart';

/// Bottom panel shown when no vehicle is selected: explains the icons and
/// lets the user filter the map by vehicle type.
class VehicleLegend extends StatelessWidget {
  final LiveTrackingViewModel vm;
  const VehicleLegend({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            Text(context.tr('Live vehicles'),
                style: TextStyle(
                    color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(context.tr('Tap a vehicle on the map to follow it. Tap a type to show or hide it.'),
                style: TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final t in VehicleType.values)
                  FilterChip(
                    avatar: CircleAvatar(
                      backgroundColor: styleOf(t).color,
                      child: Icon(styleOf(t).icon,
                          size: 14, color: styleOf(t).onColor),
                    ),
                    label: Text(context.tr(t.label)),
                    selected: !vm.hiddenTypes.contains(t),
                    onSelected: (_) => vm.toggleType(t),
                    selectedColor: kCardActive,
                    backgroundColor: kBg,
                    checkmarkColor: kText,
                    side: const BorderSide(color: kBorder),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/model/bus_route.dart';

/// Icon and colours that tell the three vehicle types apart (US 4.2).
class VehicleTypeStyle {
  final IconData icon;
  final Color color;
  final Color onColor;
  const VehicleTypeStyle(this.icon, this.color, this.onColor);
}

VehicleTypeStyle styleOf(VehicleType type) => switch (type) {
      VehicleType.bigBus =>
        const VehicleTypeStyle(Icons.directions_bus, kViolet, Colors.white),
      VehicleType.microbus =>
        const VehicleTypeStyle(Icons.airport_shuttle, kAccent, kText),
      VehicleType.safaTempo =>
        const VehicleTypeStyle(Icons.electric_rickshaw, kText, Colors.white),
    };

/// A vehicle on the map: type icon, direction arrow (hidden when stationary)
/// and a ring when it is the one the camera is locked onto.
class VehicleMarker extends StatelessWidget {
  final VehicleType type;
  final double? bearing; // degrees, null = no arrow
  final bool selected;

  const VehicleMarker({
    super.key,
    required this.type,
    required this.bearing,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final style = styleOf(type);
    return Stack(
      alignment: Alignment.center,
      children: [
        if (bearing != null)
          Transform.rotate(
            angle: bearing! * pi / 180,
            // Dark arrow with a white outline so it stands out on any map colour.
            child: const Align(
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.navigation, size: 32, color: Colors.white),
                  Icon(Icons.navigation, size: 24, color: kText),
                ],
              ),
            ),
          ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: style.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? kViolet : Colors.white,
              width: selected ? 4 : 2,
            ),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Icon(style.icon, size: 20, color: style.onColor),
        ),
      ],
    );
  }
}

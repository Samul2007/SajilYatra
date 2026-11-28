import 'package:flutter/material.dart';
import 'package:sajilyatra/repository/profile_store.dart';
import 'package:sajilyatra/view/shift/shift_screen.dart';
import 'package:sajilyatra/view/tracking/live_tracking_screen.dart';

/// Where a logged-in user lands: conductors on their shift screen, everyone
/// else on the live map.
Widget homeScreen() => ProfileStore.instance.role == 'Conductor / Driver'
    ? const ShiftScreen()
    : const LiveTrackingScreen();

/// Opens [homeScreen] and clears the screens behind it (no going back to login).
void goHome(BuildContext context) => Navigator.pushAndRemoveUntil(
    context, MaterialPageRoute(builder: (_) => homeScreen()), (_) => false);

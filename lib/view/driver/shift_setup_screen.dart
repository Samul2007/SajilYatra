import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/view/tracking/live_tracking_screen.dart';

class ShiftSetupScreen extends StatefulWidget {
  final String role;

  const ShiftSetupScreen({super.key, required this.role});

  @override
  State<ShiftSetupScreen> createState() => _ShiftSetupScreenState();
}

class _ShiftSetupScreenState extends State<ShiftSetupScreen> {
  static const int _maxSeats = 60;
  int _availableSeats = 0;
  final TextEditingController _seatsController =
  TextEditingController(text: '0');

  @override
  void dispose() {
    _seatsController.dispose();
    super.dispose();
  }

  void _updateSeats(int value) {
    final clamped = value.clamp(0, _maxSeats);
    setState(() {
      _availableSeats = clamped;
      _seatsController.text = clamped.toString();
      _seatsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _seatsController.text.length),
      );
    });
  }

  void _startShift() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LiveTrackingScreen(showVehicleTypeLabels: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kText,
        elevation: 0,
        title: const Text('Shift setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start your shift',
                style: TextStyle(
                  color: kText,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kViolet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Role: ${widget.role}',
                  style: const TextStyle(
                    color: kViolet,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Number of available seats',
                style: TextStyle(
                  color: kText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Commuters will see how many seats are open before boarding.',
                style: TextStyle(color: kMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder, width: 1.5),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _availableSeats > 0
                          ? () => _updateSeats(_availableSeats - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: kAccent,
                      iconSize: 28,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _seatsController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: kText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'seats',
                          suffixStyle: TextStyle(color: kMuted, fontSize: 14),
                        ),
                        onChanged: (raw) {
                          final parsed = int.tryParse(raw.trim());
                          if (parsed != null) {
                            final clamped = parsed.clamp(0, _maxSeats);
                            _availableSeats = clamped;
                            if (clamped != parsed) {
                              _updateSeats(clamped);
                            }
                          }
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _availableSeats < _maxSeats
                          ? () => _updateSeats(_availableSeats + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: kAccent,
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startShift,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    'Start shift ($_availableSeats seats open)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: kOnAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';

class ShiftSetupScreen extends StatefulWidget {
  final String role;

  const ShiftSetupScreen({super.key, required this.role});

  @override
  State<ShiftSetupScreen> createState() => _ShiftSetupScreenState();
}

class _ShiftSetupScreenState extends State<ShiftSetupScreen> {
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
            ],
          ),
        ),
      ),
    );
  }
}
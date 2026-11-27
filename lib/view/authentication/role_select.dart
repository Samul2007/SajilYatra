import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/view/authentication/register_screen.dart';
import 'package:sajilyatra/view/authentication/widgets/role_card.dart';
import 'package:sajilyatra/view/driver/shift_setup_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String selectedRole = 'Commuter';

  void _onContinue() {
    final isDriver = selectedRole == 'Conductor / Driver';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isDriver
            ? ShiftSetupScreen(role: selectedRole)
            : RegisterScreen(role: selectedRole),
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your profile',
                style: TextStyle(
                  color: kText,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you travel or operate in Kathmandu Valley so we can tailor fares and routes for you.',
                style: TextStyle(
                  color: kMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SELECT ROLE',
                style: TextStyle(
                  color: kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              RoleCard(
                icon: Icons.directions_bus_outlined,
                title: 'Commuter',
                subtitle: 'Regular daily passenger with standard fare',
                isSelected: selectedRole == 'Commuter',
                onTap: () {
                  setState(() {
                    selectedRole = 'Commuter';
                  });
                },
              ),
              const SizedBox(height: 12),
              RoleCard(
                icon: Icons.school_outlined,
                title: 'Student',
                subtitle: 'Eligible for 45% student fare discount',
                isSelected: selectedRole == 'Student',
                onTap: () {
                  setState(() {
                    selectedRole = 'Student';
                  });
                },
              ),
              const SizedBox(height: 12),
              RoleCard(
                icon: Icons.elderly_outlined,
                title: 'Senior Citizen',
                subtitle: 'Eligible for senior citizen fare concession',
                isSelected: selectedRole == 'Senior Citizen',
                onTap: () {
                  setState(() {
                    selectedRole = 'Senior Citizen';
                  });
                },
              ),
              const SizedBox(height: 12),
              RoleCard(
                icon: Icons.badge_outlined,
                title: 'Conductor / Driver',
                subtitle: 'Share live vehicle location and manage routes',
                isSelected: selectedRole == 'Conductor / Driver',
                onTap: () {
                  setState(() {
                    selectedRole = 'Conductor / Driver';
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: kOnAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

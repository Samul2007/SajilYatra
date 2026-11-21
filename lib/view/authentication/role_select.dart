import 'package:flutter/material.dart';
import 'package:sajilyatra/view/authentication/register_screen.dart';
import 'package:sajilyatra/view/authentication/widgets/role_card.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String selectedRole = 'Commuter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you travel or operate in Kathmandu Valley so we can tailor fares and routes for you.',
                style: TextStyle(
                  color: Color(0xFF8E999E),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'SELECT ROLE',
                style: TextStyle(
                  color: Color(0xFF6F7B80),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              // Role options
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

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(role: selectedRole),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28B89D),
                    foregroundColor: const Color(0xFF061310),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
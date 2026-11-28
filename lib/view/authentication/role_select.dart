import 'package:flutter/material.dart';
import 'package:sajilyatra/l10n/language_toggle.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/constants/app_colors.dart';
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
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [LanguageToggle()],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
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
              Text(
                context.tr('Choose your profile'),
                style: TextStyle(
                  color: kText,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('Select how you travel or operate in Kathmandu Valley so we can tailor fares and routes for you.'),
                style: TextStyle(
                  color: kMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                context.tr('SELECT ROLE'),
                style: TextStyle(
                  color: kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              // Role options
              RoleCard(
                icon: Icons.directions_bus_outlined,
                title: context.tr('Commuter'),
                subtitle: context.tr('Regular daily passenger with standard fare'),
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
                title: context.tr('Student'),
                subtitle: context.tr('Eligible for 45% student fare discount'),
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
                title: context.tr('Senior Citizen'),
                subtitle: context.tr('Eligible for senior citizen fare concession'),
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
                title: context.tr('Conductor / Driver'),
                subtitle: context.tr('Share live vehicle location and manage routes'),
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
                    backgroundColor: kAccent,
                    foregroundColor: kOnAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    context.tr('Continue'),
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
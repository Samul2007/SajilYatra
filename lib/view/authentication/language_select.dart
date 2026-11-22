import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/view/authentication/role_select.dart';
import 'package:sajilyatra/view/authentication/widgets/language_card.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Logo box
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFE552),
                      kAccent,
                    ],
                  ),
                ),
                child: Image.asset(
                  'assets/icons/s.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Title & Devanagari subtitle
              const Text(
                'Sajil Yatra',
                style: TextStyle(
                  color: kText,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'सजिल यात्रा',
                style: TextStyle(
                  color: kViolet,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              const Text(
                'Every bus, micro and Safa Tempo in Kathmandu Valley, live on one map.',
                style: TextStyle(
                  color: kMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Section header
              const Text(
                'CHOOSE YOUR LANGUAGE',
                style: TextStyle(
                  color: kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              // Language options
              LanguageCard(
                label: 'English',
                isSelected: selectedLanguage == 'English',
                onTap: () {
                  setState(() {
                    selectedLanguage = 'English';
                  });
                },
              ),
              const SizedBox(height: 12),
              LanguageCard(
                label: 'नेपाली',
                isSelected: selectedLanguage == 'नेपाली',
                onTap: () {
                  setState(() {
                    selectedLanguage = 'नेपाली';
                  });
                },
              ),

              const Spacer(flex: 4),

              // Get started button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoleSelectScreen(),
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
                  child: const Text(
                    'Get started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Login prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: kMuted,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to login screen
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: kViolet,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
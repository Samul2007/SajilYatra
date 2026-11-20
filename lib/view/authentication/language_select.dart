import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF0B0E0F),
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
                      Color(0xFF43C6AC),
                      Color(0xFF145A52),
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
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'सजिल यात्रा',
                style: TextStyle(
                  color: Color(0xFFD97724),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              const Text(
                'Every bus, micro and Safa Tempo in Kathmandu Valley, live on one map.',
                style: TextStyle(
                  color: Color(0xFF8E999E),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Section header
              const Text(
                'CHOOSE YOUR LANGUAGE',
                style: TextStyle(
                  color: Color(0xFF6F7B80),
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

              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
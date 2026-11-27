import 'package:flutter/material.dart';
import 'package:sajilyatra/view/authentication/login_screen.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/view/authentication/role_select.dart';
import 'package:sajilyatra/view/authentication/widgets/language_card.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
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
              Text(
                context.tr('Every bus, micro and Safa Tempo in Kathmandu Valley, live on one map.'),
                style: TextStyle(
                  color: kMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Section header
              Text(
                context.tr('CHOOSE YOUR LANGUAGE'),
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
                isSelected: !AppLanguage.instance.isNepali,
                onTap: () => AppLanguage.instance.setNepali(false),
              ),
              const SizedBox(height: 12),
              LanguageCard(
                label: 'नेपाली',
                isSelected: AppLanguage.instance.isNepali,
                onTap: () => AppLanguage.instance.setNepali(true),
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
                  child: Text(
                    context.tr('Get started'),
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
                  Text(
                    context.tr('Already have an account? '),
                    style: TextStyle(
                      color: kMuted,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginScreen())),
                    child: Text(
                      context.tr('Log in'),
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
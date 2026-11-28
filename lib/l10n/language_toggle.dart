import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';
import 'package:sajilyatra/l10n/app_language.dart';

/// Small button that switches the whole app between English and Nepali.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.instance;
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => TextButton.icon(
        onPressed: () => lang.setNepali(!lang.isNepali),
        icon: const Icon(Icons.translate, size: 18, color: kViolet),
        // Shows the language you would switch to.
        label: Text(lang.isNepali ? 'English' : 'नेपाली',
            style:
                const TextStyle(color: kViolet, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

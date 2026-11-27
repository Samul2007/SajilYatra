import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sajilyatra/firebase_options.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/repository/emergency_contacts_store.dart';
import 'package:sajilyatra/repository/panic_service.dart';
import 'package:sajilyatra/repository/panic_settings.dart';
import 'package:sajilyatra/repository/profile_store.dart';
import 'package:sajilyatra/view/home.dart';
import 'package:sajilyatra/view/authentication/language_select.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // The app still works without Firebase; only Google sign-in needs it.
    debugPrint('Firebase did not start: $e');
  }
  await AppLanguage.instance.load();
  await ProfileStore.instance.load();
  await AccountStore.instance.load();
  await EmergencyContactsStore.instance.load();
  await PanicSettings.instance.load();
  PanicService.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguage.instance,
      builder: (context, _) => MaterialApp(
        scaffoldMessengerKey: rootMessengerKey,
        debugShowCheckedModeBanner: false,
        locale: AppLanguage.instance.locale,
        supportedLocales: const [Locale('en'), Locale('ne')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // The session stays active until the user logs out.
        home: AccountStore.instance.loggedIn
            ? homeScreen()
            : const LanguageSelectScreen(),
      ),
    );
  }
}

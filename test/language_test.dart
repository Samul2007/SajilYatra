import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/l10n/ne_strings.dart';
import 'package:sajilyatra/view/authentication/login_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.instance.isNepali = false;
  });

  test('translates, fills {} and writes Nepali numerals', () async {
    expect(trNow('Login'), 'Login');

    await AppLanguage.instance.setNepali(true);
    expect(trNow('Login'), 'लगइन');
    expect(trNow('{} min', [14]), '१४ मिनेट');
    expect(trNow('text with no translation'), 'text with no translation');
  });

  test('the language choice is saved and loaded', () async {
    await AppLanguage.instance.setNepali(true);
    AppLanguage.instance.isNepali = false; // forget it in memory

    await AppLanguage.instance.load();
    expect(AppLanguage.instance.isNepali, isTrue);
  });

  test('every {} template keeps its {} in Nepali', () {
    for (final e in neStrings.entries) {
      expect('{}'.allMatches(e.key).length, '{}'.allMatches(e.value).length,
          reason: e.key);
    }
  });

  testWidgets('the toggle switches a screen to Nepali and back', (tester) async {
    await tester.pumpWidget(ListenableBuilder(
      listenable: AppLanguage.instance,
      builder: (context, _) => MaterialApp(
        locale: AppLanguage.instance.locale,
        supportedLocales: const [Locale('en'), Locale('ne')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LoginScreen(),
      ),
    ));
    expect(find.text('Sign in'), findsOneWidget);

    await tester.tap(find.text('नेपाली'));
    await tester.pumpAndSettle();
    expect(find.text('साइन इन'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/model/phone.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/repository/google_auth.dart';
import 'package:sajilyatra/view/authentication/register_screen.dart';

class FakeGoogle extends GoogleAuth {
  FakeGoogle(this.result, {this.fails = false});
  final GoogleAccount? result;
  final bool fails;
  @override
  Future<GoogleAccount?> signIn() async {
    if (fails) throw Exception('Google is not enabled');
    return result;
  }
}

Future<void> fillForm(WidgetTester tester, String phone) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Kritesh');
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'k@x.com');
  await tester.enterText(find.widgetWithText(TextFormField, 'Phone number'), phone);
  await tester.tap(find.text('Send OTP'));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AccountStore.instance
      ..phone = null
      ..email = null
      ..loggedIn = false;
  });

  test('only 98 and 97 mobile numbers of 10 digits are valid', () {
    expect(isNepaliMobile('9841234567'), isTrue); // NTC
    expect(isNepaliMobile('9801234567'), isTrue); // Ncell
    expect(isNepaliMobile('9741234567'), isTrue);
    expect(isNepaliMobile('9641234567'), isFalse);
    expect(isNepaliMobile('984123456'), isFalse); // 9 digits
    expect(isNepaliMobile('98412345678'), isFalse); // 11 digits
    expect(isNepaliMobile('98a1234567'), isFalse);
  });

  testWidgets('a number that does not start with 98 or 97 is refused',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen(role: 'Student')));
    await fillForm(tester, '9612345678');
    expect(find.text('Enter a valid mobile number (starts with 98 or 97)'),
        findsOneWidget);
    expect(find.textContaining('Demo SMS'), findsNothing);
  });

  testWidgets('a wrong code does not create the account', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen(role: 'Student')));
    await fillForm(tester, '9841234567');
    expect(find.textContaining('Demo SMS'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '12345'); // never a valid code
    await tester.tap(find.text('Verify'));
    await tester.pump();
    expect(find.text('Wrong code. Try again.'), findsOneWidget);
    expect(AccountStore.instance.phone, isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the right code creates the account and moves on',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen(role: 'Student')));
    await fillForm(tester, '9841234567');
    expect(AccountStore.instance.phone, isNull); // not yet: the OTP comes first

    final shown = tester.widget<Text>(find.textContaining('Demo SMS')).data!;
    final code = RegExp(r'\d{6}').firstMatch(shown)!.group(0)!;
    await tester.enterText(find.byType(TextField), code);
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(AccountStore.instance.isRegistered('9841234567'), isTrue);
    expect(AccountStore.instance.loggedIn, isTrue);
    expect(find.text('My profile'), findsOneWidget); // Students go on to upload an ID
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Continue with Google creates the account and moves on',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(
            role: 'Student',
            googleAuth: FakeGoogle(const GoogleAccount('Kritesh', 'k@gmail.com')))));
    await tester.ensureVisible(find.text('Google'));
    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();

    expect(AccountStore.instance.email, 'k@gmail.com');
    expect(AccountStore.instance.loggedIn, isTrue);
    expect(find.text('My profile'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('closing the Google page creates nothing', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(role: 'Student', googleAuth: FakeGoogle(null))));
    await tester.ensureVisible(find.text('Google'));
    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();

    expect(AccountStore.instance.loggedIn, isFalse);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('a Google error is shown to the user', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(
            role: 'Student', googleAuth: FakeGoogle(null, fails: true))));
    await tester.ensureVisible(find.text('Google'));
    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();

    expect(find.text('Google sign-in did not work. Try again.'), findsOneWidget);
    expect(AccountStore.instance.loggedIn, isFalse);
  });
}

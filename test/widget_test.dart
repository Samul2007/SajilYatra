import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/repository/account_store.dart';
import 'package:sajilyatra/repository/biometric_auth.dart';
import 'package:sajilyatra/view/authentication/login_screen.dart';

class FakeBiometric extends BiometricAuth {
  FakeBiometric({this.passes = false});
  final bool passes;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> authenticate(String reason) async => passes;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final a = AccountStore.instance;
    await a.register(name: 'Kritesh', phone: '9801234567', email: 'k@x.com');
    await a.logOut();
  });

  testWidgets('an unregistered number is refused', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(biometric: FakeBiometric())));
    await tester.enterText(find.byType(TextField), '9800000000');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    expect(find.text('This number is not registered. Sign up first.'),
        findsOneWidget);
  });

  testWidgets('a registered number gets a code and can enter it',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(biometric: FakeBiometric())));
    await tester.enterText(find.byType(TextField), '9801234567');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    expect(find.textContaining('Demo SMS: your Sajil Yatra code is'),
        findsOneWidget);

    await tester.enterText(find.byType(TextField), '12345'); // never a valid 6-digit code
    await tester.tap(find.text('Verify'));
    await tester.pump();
    expect(find.text('Wrong code. Try again.'), findsOneWidget);
    // Leave the screen so its resend timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a failed fingerprint falls back to an OTP', (tester) async {
    await AccountStore.instance.setBiometric(true);
    await tester.pumpWidget(MaterialApp(home: LoginScreen(biometric: FakeBiometric())));
    await tester.pump(); // let isAvailable() finish

    await tester.tap(find.text('Log in with fingerprint / Face ID'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Fingerprint did not work. Log in with an OTP instead.'),
        findsOneWidget);
    expect(find.textContaining('Demo SMS: your Sajil Yatra code is'),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

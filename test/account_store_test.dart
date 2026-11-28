import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/repository/account_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('registering creates the account and logs in', () async {
    final a = AccountStore();
    expect(a.loggedIn, isFalse);
    await a.register(name: 'Kritesh', phone: '9801234567', email: 'k@x.com');
    expect(a.loggedIn, isTrue);
    expect(a.isRegistered('9801234567'), isTrue);
    expect(a.isRegistered('9800000000'), isFalse);
  });

  test('the session stays active after a restart until log out', () async {
    final a = AccountStore();
    await a.register(name: 'Kritesh', phone: '9801234567', email: 'k@x.com');

    final restarted = AccountStore();
    await restarted.load();
    expect(restarted.loggedIn, isTrue);

    await restarted.logOut();
    final again = AccountStore();
    await again.load();
    expect(again.loggedIn, isFalse);
    expect(again.isRegistered('9801234567'), isTrue); // account is kept
  });

  test('the fingerprint choice is saved', () async {
    final a = AccountStore();
    await a.register(name: 'Kritesh', phone: '9801234567', email: 'k@x.com');
    await a.setBiometric(true);

    final b = AccountStore();
    await b.load();
    expect(b.biometricEnabled, isTrue);
    expect(b.biometricAsked, isTrue);
  });

  test('Google sign-up creates an account without a phone number', () async {
    final a = AccountStore();
    await a.signInWithGoogle(name: 'Kritesh', email: 'k@gmail.com');
    expect(a.loggedIn, isTrue);
    expect(a.phone, isNull);
    expect(a.isRegistered('9801234567'), isFalse);

    final restarted = AccountStore();
    await restarted.load();
    expect(restarted.loggedIn, isTrue); // the session survives a restart
  });

  test('signing in with the same Google account keeps the phone number',
      () async {
    final a = AccountStore();
    await a.register(name: 'Kritesh', phone: '9801234567', email: 'k@gmail.com');
    await a.logOut();

    await a.signInWithGoogle(name: 'Kritesh', email: 'k@gmail.com');
    expect(a.loggedIn, isTrue);
    expect(a.isRegistered('9801234567'), isTrue);
  });
}

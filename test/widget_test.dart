import 'package:flutter_test/flutter_test.dart';
import 'package:sajilyatra/view/authentication/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('login shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/model/profile.dart';
import 'package:sajilyatra/repository/profile_store.dart';
import 'package:sajilyatra/view/shift/shift_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a commuter needs no ID and is unlocked at once', () {
    final store = ProfileStore();
    expect(store.needsId, isFalse);
    expect(store.isUnlocked, isTrue);
  });

  test('ID profiles stay locked until verified', () async {
    final store = ProfileStore();
    await store.setRole('Student');
    expect(store.needsId, isTrue);
    expect(store.isUnlocked, isFalse);

    await store.submitId('/tmp/id.jpg');
    expect(store.status, VerificationStatus.pending);
    expect(store.isUnlocked, isFalse);

    await store.review(approved: true);
    expect(store.status, VerificationStatus.verified);
    expect(store.isUnlocked, isTrue);
  });

  test('a rejected ID can be uploaded again', () async {
    final store = ProfileStore();
    await store.setRole('Senior Citizen');
    await store.submitId('/tmp/a.jpg');
    await store.review(approved: false);
    expect(store.status, VerificationStatus.rejected);

    await store.submitId('/tmp/b.jpg');
    expect(store.status, VerificationStatus.pending);
  });

  test('only a verified conductor counts as a verified conductor', () async {
    final store = ProfileStore();
    await store.setRole('Student');
    await store.submitId('/tmp/id.jpg');
    await store.review(approved: true);
    expect(store.isVerifiedConductor, isFalse); // verified, but a student

    await store.setRole('Conductor / Driver'); // new type clears the old ID
    expect(store.status, VerificationStatus.notSubmitted);
    await store.submitId('/tmp/id2.jpg');
    await store.review(approved: true);
    expect(store.isVerifiedConductor, isTrue);
  });

  test('a commuter cannot submit an ID and review needs a pending ID', () async {
    final store = ProfileStore();
    await store.submitId('/tmp/id.jpg');
    expect(store.status, VerificationStatus.notSubmitted);

    await store.setRole('Student');
    await store.review(approved: true); // nothing pending yet
    expect(store.status, VerificationStatus.notSubmitted);
  });

  test('the profile is saved and loaded', () async {
    final a = ProfileStore();
    await a.setRole('Student');
    await a.submitId('/tmp/id.jpg');

    final b = ProfileStore();
    await b.load();
    expect(b.role, 'Student');
    expect(b.status, VerificationStatus.pending);
    expect(b.idPhotoPath, '/tmp/id.jpg');
  });

  testWidgets('the shift screen tells an unverified user to verify first',
      (tester) async {
    ProfileStore.instance.role = 'Commuter';
    ProfileStore.instance.status = VerificationStatus.notSubmitted;

    await tester.pumpWidget(const MaterialApp(home: ShiftScreen()));
    expect(find.text('Only verified conductors can start a shift.'),
        findsOneWidget);
    expect(find.text('Verify my ID'), findsOneWidget);
  });
}

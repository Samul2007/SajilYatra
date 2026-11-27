import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilyatra/l10n/app_language.dart';
import 'package:sajilyatra/repository/emergency_contacts_store.dart';
import 'package:sajilyatra/repository/sos_service.dart';
import 'package:sajilyatra/view/safety/sos_button.dart';

class FakeSos extends SosService {
  int triggered = 0;
  List<EmergencyContact> sentTo = [];

  @override
  Future<SosOutcome> trigger({
    required List<EmergencyContact> contacts,
    required String name,
    bool silent = false,
  }) async {
    triggered++;
    sentTo = List.of(contacts);
    return SosOutcome(List.of(contacts), true, const LatLng(27.6945, 85.3139));
  }
}

Future<void> openSos(WidgetTester tester, FakeSos sos) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(floatingActionButton: SosButton(service: sos)),
  ));
  await tester.tap(find.text('SOS'));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.instance.isNepali = false;
    EmergencyContactsStore.instance.contacts.clear();
  });

  group('message', () {
    final noon = DateTime(2026, 11, 27, 12, 30);

    test('contains the name, a map link and the time', () {
      final text = sosMessage(
          name: 'Kritesh', time: noon, position: const LatLng(27.6945, 85.3139));
      expect(text, contains('Kritesh'));
      expect(text, contains('https://maps.google.com/?q=27.694500,85.313900'));
      expect(text, contains('12:30'));
    });

    test('says so when there is no location', () {
      final text = sosMessage(name: 'Kritesh', time: noon);
      expect(text, contains('Location not available'));
      expect(text, isNot(contains('maps.google.com')));
    });

    test('in Nepali the map link keeps normal digits so it still opens', () async {
      await AppLanguage.instance.setNepali(true);
      final text = sosMessage(
          name: 'Kritesh', time: noon, position: const LatLng(27.6945, 85.3139));
      expect(text, contains('https://maps.google.com/?q=27.694500,85.313900'));
      expect(text, contains('१२:३०')); // the time is in Nepali numerals
      expect(text, contains('एसओएस'));
    });
  });

  group('contacts', () {
    test('at most 3, no duplicates, and they are saved', () async {
      final store = EmergencyContactsStore();
      expect(await store.add('Mum', '9841111111'), isTrue);
      expect(await store.add('Mum again', '9841111111'), isFalse);
      expect(await store.add('Dad', '9842222222'), isTrue);
      expect(await store.add('Sis', '9843333333'), isTrue);
      expect(store.isFull, isTrue);
      expect(await store.add('Extra', '9844444444'), isFalse);

      final reloaded = EmergencyContactsStore();
      await reloaded.load();
      expect(reloaded.contacts.map((c) => c.name), ['Mum', 'Dad', 'Sis']);

      await reloaded.remove(reloaded.contacts.first);
      expect(reloaded.contacts.length, 2);
    });
  });

  group('SOS button', () {
    testWidgets('cancelling the countdown sends nothing', (tester) async {
      final sos = FakeSos();
      await openSos(tester, sos);
      expect(find.text('SOS in 3 seconds'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(sos.triggered, 0);
    });

    testWidgets('after 3 seconds the alert goes to the saved contacts',
        (tester) async {
      EmergencyContactsStore.instance.contacts
          .add(const EmergencyContact('Mum', '9841111111'));
      final sos = FakeSos();
      await openSos(tester, sos);

      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      expect(sos.triggered, 1);
      expect(sos.sentTo.single.name, 'Mum');
      expect(find.text('SOS alert prepared'), findsOneWidget);
      expect(find.text('Mum · message opened'), findsOneWidget);
      expect(find.text('Nepal Police (100)'), findsOneWidget);
      expect(find.text('Transit dispatch: not connected yet'), findsOneWidget);
    });

    testWidgets('with no contacts it asks you to add some', (tester) async {
      final sos = FakeSos();
      await openSos(tester, sos);
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      expect(find.text('No emergency contacts saved. Add some so they get your location.'),
          findsOneWidget);
      expect(find.text('Nepal Police (100)'), findsOneWidget); // can still call
    });
  });
}

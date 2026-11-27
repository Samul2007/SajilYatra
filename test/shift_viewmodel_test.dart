import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilyatra/model/shift.dart';
import 'package:sajilyatra/repository/shift_repository.dart';
import 'package:sajilyatra/viewmodel/shift_viewmodel.dart';

class FakeShiftRepository implements ShiftRepository {
  final controller = StreamController<BroadcastPoint>.broadcast();
  final sent = <BroadcastPoint>[];
  String? prepareError;

  @override
  Future<String?> prepare() async => prepareError;
  @override
  Stream<BroadcastPoint> watchPoints() => controller.stream;
  @override
  void broadcast(Shift shift, BroadcastPoint point) => sent.add(point);
}

BroadcastPoint point() =>
    BroadcastPoint(const LatLng(27.69, 85.31), 18, DateTime.now());

void main() {
  test('shift broadcasts only between start and end', () async {
    final repo = FakeShiftRepository();
    final vm = ShiftViewModel(repository: repo);

    repo.controller.add(point()); // before the shift: nothing listens
    await Future<void>.delayed(Duration.zero);
    expect(repo.sent, isEmpty);

    await vm.start();
    expect(vm.isActive, isTrue);
    repo.controller.add(point());
    await Future<void>.delayed(Duration.zero);
    expect(repo.sent.length, 1);
    expect(vm.broadcastCount, 1);

    await vm.end();
    expect(vm.isActive, isFalse);
    expect(repo.controller.hasListener, isFalse); // broadcasting stopped
  });

  test('shift does not start without GPS permission', () async {
    final repo = FakeShiftRepository()..prepareError = 'Allow location';
    final vm = ShiftViewModel(repository: repo);
    await vm.start();
    expect(vm.isActive, isFalse);
    expect(vm.error, 'Allow location');
  });

  test('unverified conductor cannot start a shift', () async {
    final vm = ShiftViewModel(repository: FakeShiftRepository(), isVerified: false);
    await vm.start();
    expect(vm.isActive, isFalse);
    expect(vm.error, isNotNull);
  });
}

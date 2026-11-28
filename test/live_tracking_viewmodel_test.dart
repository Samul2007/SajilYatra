import 'package:flutter_test/flutter_test.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/viewmodel/live_tracking_viewmodel.dart';

void main() {
  test('select locks onto a vehicle and release frees the camera', () {
    final vm = LiveTrackingViewModel();
    expect(vm.selected, isNull);

    vm.select(BusRoute.kalankiKoteshwor);
    expect(vm.selected, BusRoute.kalankiKoteshwor);

    vm.release();
    expect(vm.selected, isNull);
    vm.dispose();
  });

  test('hiding a vehicle type hides its vehicles and drops a selection of it', () {
    final vm = LiveTrackingViewModel();
    vm.select(BusRoute.kalankiRatnapark); // the only Big Bus

    vm.toggleType(VehicleType.bigBus);
    expect(vm.isVisible(BusRoute.kalankiRatnapark), isFalse);
    expect(vm.isVisible(BusRoute.kalankiKoteshwor), isTrue);
    expect(vm.selected, isNull);

    vm.toggleType(VehicleType.bigBus);
    expect(vm.isVisible(BusRoute.kalankiRatnapark), isTrue);
    vm.dispose();
  });

  test('every route has a type and all three types appear', () {
    expect(BusRoute.all.map((r) => r.type).toSet(), VehicleType.values.toSet());
  });
}

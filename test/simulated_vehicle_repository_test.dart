import 'package:flutter_test/flutter_test.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/repository/vehicle_repository.dart';

void main() {
  test('simulated bus moves, stops at stops and stays on the route', () async {
    final repo = SimulatedVehicleRepository(
      tick: const Duration(milliseconds: 1),
      timeScale: 100000, // 100 simulated seconds per tick
    );
    final updates =
        await repo.watch(BusRoute.kalankiKoteshwor).take(400).toList();

    expect(updates.every((u) => u.speedKmh >= 0 && u.speedKmh <= 26), isTrue);
    expect(updates.any((u) => u.isStanding), isTrue);
    expect(updates.any((u) => u.speedKmh > 0), isTrue);
    expect(updates.map((u) => u.nextStop.name).toSet().length, greaterThan(1));
    // Kathmandu valley bounding box.
    expect(
      updates.every((u) =>
          u.position.latitude > 27.6 &&
          u.position.latitude < 27.8 &&
          u.position.longitude > 85.2 &&
          u.position.longitude < 85.4),
      isTrue,
    );
  });
}

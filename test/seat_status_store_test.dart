import 'package:flutter_test/flutter_test.dart';
import 'package:sajilyatra/model/bus_route.dart';
import 'package:sajilyatra/model/seat_status.dart';
import 'package:sajilyatra/repository/seat_status_store.dart';

void main() {
  test('seat status is stored per route with a timestamp and notifies', () {
    final store = SeatStatusStore();
    var notified = 0;
    store.addListener(() => notified++);

    expect(store.of(BusRoute.kalankiKoteshwor), isNull);

    store.set(BusRoute.kalankiKoteshwor, SeatStatus.packed);
    expect(store.of(BusRoute.kalankiKoteshwor)!.status, SeatStatus.packed);
    expect(store.of(BusRoute.ratnaparkBhaktapur), isNull);
    expect(notified, 1);

    store.set(BusRoute.kalankiKoteshwor, SeatStatus.empty);
    expect(store.of(BusRoute.kalankiKoteshwor)!.status, SeatStatus.empty);
  });
}

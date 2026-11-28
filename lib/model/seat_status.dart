enum SeatStatus {
  empty('Empty'),
  standing('Standing'),
  packed('Packed');

  const SeatStatus(this.label);
  final String label;
}

class SeatUpdate {
  final SeatStatus status;
  final DateTime updatedAt;
  const SeatUpdate(this.status, this.updatedAt);
}

class HallInfo {
  final String id;
  final int rowsCount;
  final int seatsPerRow;
  final int capacity;

  const HallInfo({
    required this.id,
    required this.rowsCount,
    required this.seatsPerRow,
    required this.capacity,
  });

  factory HallInfo.fromJson(Map<String, dynamic> json) {
    return HallInfo(
      id: (json['id'] ?? '').toString(),
      rowsCount: (json['rowsCount'] ?? 0) as int,
      seatsPerRow: (json['seatsPerRow'] ?? 0) as int,
      capacity: (json['capacity'] ?? 0) as int,
    );
  }
}

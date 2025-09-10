class HomeKpisDto {
  final int reservationsToday;
  final double revenueMonth;
  final double avgOccupancy;

  HomeKpisDto({
    required this.reservationsToday,
    required this.revenueMonth,
    required this.avgOccupancy,
  });

  factory HomeKpisDto.fromJson(Map<String, dynamic> json) {
    return HomeKpisDto(
      reservationsToday: (json['reservationsToday'] as num?)?.toInt() ?? 0,
      revenueMonth: (json['revenueMonth'] as num?)?.toDouble() ?? 0.0,
      avgOccupancy: (json['avgOccupancy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservationsToday': reservationsToday,
      'revenueMonth': revenueMonth,
      'avgOccupancy': avgOccupancy,
    };
  }
}

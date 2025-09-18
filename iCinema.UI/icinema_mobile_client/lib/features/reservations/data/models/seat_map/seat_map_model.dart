import 'projection_info.dart';
import 'hall_info.dart';
import 'seat_info.dart';

class SeatMapModel {
  final ProjectionInfo projection;
  final HallInfo hall;
  final List<SeatInfo> seats;

  const SeatMapModel({
    required this.projection,
    required this.hall,
    required this.seats,
  });

  factory SeatMapModel.fromJson(Map<String, dynamic> json) {
    return SeatMapModel(
      projection: ProjectionInfo.fromJson(json['projection'] as Map<String, dynamic>),
      hall: HallInfo.fromJson(json['hall'] as Map<String, dynamic>),
      seats: ((json['seats'] as List?) ?? const [])
          .map((e) => SeatInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProjectionInfo {
  final String id;
  final DateTime startTime;
  final double price;
  final String hallName;
  final String cinemaName;
  final String movieId;
  final String movieTitle;
  final String? posterUrl;

  const ProjectionInfo({
    required this.id,
    required this.startTime,
    required this.price,
    required this.hallName,
    required this.cinemaName,
    required this.movieId,
    required this.movieTitle,
    this.posterUrl,
  });

  factory ProjectionInfo.fromJson(Map<String, dynamic> json) {
    return ProjectionInfo(
      id: (json['id'] ?? '').toString(),
      startTime: DateTime.tryParse((json['startTime'] ?? '').toString()) ?? DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      hallName: (json['hallName'] ?? '').toString(),
      cinemaName: (json['cinemaName'] ?? '').toString(),
      movieId: (json['movieId'] ?? '').toString(),
      movieTitle: (json['movieTitle'] ?? '').toString(),
      posterUrl: (json['posterUrl'] as String?),
    );
  }
}

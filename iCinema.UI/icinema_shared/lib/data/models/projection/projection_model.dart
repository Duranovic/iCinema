import '../movie/movie_model.dart';

class ProjectionModel {
  final String? id;
  final String? movieId;
  final String movieTitle;
  final String? cinemaId;
  final String? cinemaName;
  final String? hallId;
  final String hallName;
  final DateTime startTime;
  final double price;
  final bool isActive;
  final MovieModel? movie;

  const ProjectionModel({
    this.id,
    this.movieId,
    required this.movieTitle,
    this.cinemaId,
    this.cinemaName,
    this.hallId,
    required this.hallName,
    required this.startTime,
    required this.price,
    this.isActive = true,
    this.movie,
  });

  factory ProjectionModel.fromJson(Map<String, dynamic> json) {
    return ProjectionModel(
      id: json['id'] as String?,
      movieId: json['movieId'] as String?,
      movieTitle: json['movieTitle'] as String? ?? '',
      cinemaId: json['cinemaId'] as String?,
      cinemaName: json['cinemaName'] as String?,
      hallId: json['hallId'] as String?,
      hallName: json['hallName'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      movie: json['movie'] is Map<String, dynamic>
          ? MovieModel.fromJson(json['movie'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (movieId != null) 'movieId': movieId,
      'movieTitle': movieTitle,
      if (cinemaId != null) 'cinemaId': cinemaId,
      if (cinemaName != null) 'cinemaName': cinemaName,
      if (hallId != null) 'hallId': hallId,
      'hallName': hallName,
      'startTime': startTime.toIso8601String(),
      'price': price,
      'isActive': isActive,
      if (movie != null) 'movie': movie!.toJson(),
    };
  }

  ProjectionModel copyWith({
    String? id,
    String? movieId,
    String? movieTitle,
    String? cinemaId,
    String? cinemaName,
    String? hallId,
    String? hallName,
    DateTime? startTime,
    double? price,
    bool? isActive,
    MovieModel? movie,
  }) {
    return ProjectionModel(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      cinemaId: cinemaId ?? this.cinemaId,
      cinemaName: cinemaName ?? this.cinemaName,
      hallId: hallId ?? this.hallId,
      hallName: hallName ?? this.hallName,
      startTime: startTime ?? this.startTime,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      movie: movie ?? this.movie,
    );
  }

  /// Get the date portion only (no time)
  DateTime get date => DateTime(startTime.year, startTime.month, startTime.day);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectionModel(id: $id, movieTitle: $movieTitle, startTime: $startTime, price: $price)';
  }
}


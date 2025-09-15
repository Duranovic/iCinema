class ProjectionModel {
  final String id;
  final String movieId;
  final String movieTitle;
  final String cinemaId;
  final String cinemaName;
  final String hallId;
  final String hallName;
  final DateTime startTime;
  final double price;

  const ProjectionModel({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.cinemaId,
    required this.cinemaName,
    required this.hallId,
    required this.hallName,
    required this.startTime,
    required this.price,
  });

  factory ProjectionModel.fromJson(Map<String, dynamic> json) {
    return ProjectionModel(
      id: json['id'] as String,
      movieId: json['movieId'] as String,
      movieTitle: json['movieTitle'] as String,
      cinemaId: json['cinemaId'] as String,
      cinemaName: json['cinemaName'] as String,
      hallId: json['hallId'] as String,
      hallName: json['hallName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'cinemaId': cinemaId,
      'cinemaName': cinemaName,
      'hallId': hallId,
      'hallName': hallName,
      'startTime': startTime.toIso8601String(),
      'price': price,
    };
  }

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

class ProjectionsResponse {
  final List<ProjectionModel> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const ProjectionsResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory ProjectionsResponse.fromJson(Map<String, dynamic> json) {
    return ProjectionsResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => ProjectionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }
}

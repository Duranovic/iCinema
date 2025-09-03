class Movie {
  final String? id;
  final String title;
  final String description;
  final int? duration;
  final DateTime? releaseDate;
  final List<String> genres;

  Movie({required this.title, required this.description, required this.genres, this.releaseDate, this.duration, this.id});

  // For easy API conversion:
  factory Movie.fromJson(dynamic json) => Movie(
    id: json['id'] as String?,
    title: json['title'] as String,
    releaseDate: json['releaseDate'] != null ? DateTime.parse(json['releaseDate']) : null,
    description: json['description'] as String,
    duration: json['duration'],
    // Normalize genres to a list of IDs. If API returns objects, pick 'id'; if strings, keep as-is.
    genres: ((json['genres'] as List<dynamic>?) ?? const [])
        .map((g) {
          if (g is Map) {
            final id = g['id'];
            if (id is String && id.isNotEmpty) return id;
            final name = g['name'];
            if (name is String && name.isNotEmpty) return name;
            return g.toString();
          }
          return g.toString();
        })
        .whereType<String>()
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'releaseDate': releaseDate?.toIso8601String().split('T').first, // Only the date!,
    'description': description,
    'duration': duration,
    'genreIds': genres
  };
}
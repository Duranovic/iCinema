class Movie {
  final String? id;
  final String title;
  final String description;
  final int? duration;
  final DateTime? releaseDate;
  final List<String> genres;
  final String? posterUrl;
  final String? posterBase64;
  final String? ageRating; // e.g., G, PG, PG-13, R, NC-17, NR
  final String? directorId;

  Movie({required this.title, required this.description, required this.genres, this.releaseDate, this.duration, this.id, this.posterUrl, this.posterBase64, this.ageRating, this.directorId});

  // For easy API conversion:
  factory Movie.fromJson(dynamic json) => Movie(
    id: json['id'] as String?,
    title: json['title'] as String,
    releaseDate: json['releaseDate'] != null ? DateTime.parse(json['releaseDate']) : null,
    description: json['description'] as String,
    duration: json['duration'],
    posterUrl: json['posterUrl'] as String?,
    posterBase64: json['posterBase64'] as String?,
    ageRating: json['ageRating'] as String?,
    directorId: json['directorId'] as String?,
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
    'genreIds': genres,
    if (posterUrl != null) 'posterUrl': posterUrl,
    if (posterBase64 != null) 'posterBase64': posterBase64,
    if (ageRating != null) 'ageRating': ageRating,
    if (directorId != null) 'directorId': directorId,
  };
}
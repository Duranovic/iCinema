class MovieModel {
  final String id;
  final String title;
  final DateTime releaseDate;
  final int? duration; // in minutes
  final String description;
  final List<String> genres;
  final String? posterUrl;

  const MovieModel({
    required this.id,
    required this.title,
    required this.releaseDate,
    this.duration,
    required this.description,
    required this.genres,
    this.posterUrl,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Nepoznat naslov',
      releaseDate: json['releaseDate'] != null 
          ? DateTime.parse(json['releaseDate'] as String)
          : DateTime.now(),
      duration: json['duration'] as int?,
      description: json['description'] as String? ?? 'Nema opisa',
      genres: json['genres'] != null 
          ? (json['genres'] as List<dynamic>).cast<String>()
          : <String>[],
      posterUrl: json['posterUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'releaseDate': releaseDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'duration': duration,
      'description': description,
      'genres': genres,
      'posterUrl': posterUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieModel &&
        other.id == id &&
        other.title == title &&
        other.releaseDate == releaseDate &&
        other.duration == duration &&
        other.description == description &&
        other.genres.length == genres.length &&
        other.genres.every((genre) => genres.contains(genre)) &&
        other.posterUrl == posterUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      releaseDate,
      duration,
      description,
      Object.hashAll(genres),
      posterUrl,
    );
  }

  @override
  String toString() {
    return 'MovieModel(id: $id, title: $title, releaseDate: $releaseDate, duration: $duration, description: $description, genres: $genres, posterUrl: $posterUrl)';
  }

  /// Get formatted duration string (e.g., "2h 30min")
  String get formattedDuration {
    if (duration == null) return 'N/A';
    
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  /// Get formatted release year
  String get releaseYear => releaseDate.year.toString();

  /// Get formatted genres string (e.g., "Action, Drama, Thriller")
  String get formattedGenres => genres.join(', ');
}

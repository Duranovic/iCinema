class CastMember {
  final String actorId;
  final String actorName;
  final String? roleName;

  const CastMember({
    required this.actorId,
    required this.actorName,
    this.roleName,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? 'Nepoznat',
      roleName: json['roleName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actorId': actorId,
      'actorName': actorName,
      if (roleName != null) 'roleName': roleName,
    };
  }
}

class MovieModel {
  final String id;
  final String title;
  final DateTime releaseDate;
  final int? duration; // in minutes
  final String description;
  final List<String> genres;
  final String? posterUrl;
  final double? averageRating; // 0-5
  final int? ratingsCount;
  final String? directorId;
  final String? directorName;
  final List<CastMember> cast;

  const MovieModel({
    required this.id,
    required this.title,
    required this.releaseDate,
    this.duration,
    required this.description,
    required this.genres,
    this.posterUrl,
    this.averageRating,
    this.ratingsCount,
    this.directorId,
    this.directorName,
    this.cast = const [],
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
      averageRating: () {
        final v = (json['averageRating']);
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
      }(),
      ratingsCount: () {
        final v = (json['ratingsCount']);
        if (v == null) return null;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString());
      }(),
      directorId: json['directorId'] as String?,
      directorName: json['directorName'] as String?,
      cast: json['cast'] != null
          ? (json['cast'] as List<dynamic>)
              .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
              .toList()
          : <CastMember>[],
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
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      if (directorId != null) 'directorId': directorId,
      if (directorName != null) 'directorName': directorName,
      'cast': cast.map((e) => e.toJson()).toList(),
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
        other.posterUrl == posterUrl &&
        other.averageRating == averageRating &&
        other.ratingsCount == ratingsCount &&
        other.directorId == directorId &&
        other.directorName == directorName &&
        other.cast.length == cast.length;
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
      averageRating,
      ratingsCount,
      directorId,
      directorName,
      Object.hashAll(cast.map((e) => e.actorId)),
    );
  }

  @override
  String toString() {
    return 'MovieModel(id: $id, title: $title, releaseDate: $releaseDate, duration: $duration, description: $description, genres: $genres, posterUrl: $posterUrl, averageRating: $averageRating, ratingsCount: $ratingsCount, directorId: $directorId, directorName: $directorName, cast: $cast)';
  }

  MovieModel copyWith({
    String? id,
    String? title,
    DateTime? releaseDate,
    int? duration,
    String? description,
    List<String>? genres,
    String? posterUrl,
    double? averageRating,
    int? ratingsCount,
    String? directorId,
    String? directorName,
    List<CastMember>? cast,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      releaseDate: releaseDate ?? this.releaseDate,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      posterUrl: posterUrl ?? this.posterUrl,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      directorId: directorId ?? this.directorId,
      directorName: directorName ?? this.directorName,
      cast: cast ?? this.cast,
    );
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

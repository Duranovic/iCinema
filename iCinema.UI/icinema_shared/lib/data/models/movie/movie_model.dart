import 'cast_member_model.dart';

class MovieModel {
  final String? id;
  final String title;
  final DateTime? releaseDate;
  final int? duration;
  final String description;
  final List<String> genres;
  final String? posterUrl;
  final String? posterBase64;
  final String? posterMimeType;
  final String? ageRating;
  final double? averageRating;
  final int? ratingsCount;
  final String? directorId;
  final String? directorName;
  final List<CastMemberModel> cast;
  final List<String> actorIds;

  const MovieModel({
    this.id,
    required this.title,
    this.releaseDate,
    this.duration,
    required this.description,
    required this.genres,
    this.posterUrl,
    this.posterBase64,
    this.posterMimeType,
    this.ageRating,
    this.averageRating,
    this.ratingsCount,
    this.directorId,
    this.directorName,
    this.cast = const [],
    this.actorIds = const [],
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Parse genres - handle both string arrays and object arrays
    final genresList = <String>[];
    final genresRaw = json['genres'] as List<dynamic>? ?? [];
    for (final g in genresRaw) {
      if (g is String) {
        genresList.add(g);
      } else if (g is Map) {
        final id = g['id'];
        if (id is String && id.isNotEmpty) {
          genresList.add(id);
        } else {
          final name = g['name'];
          if (name is String && name.isNotEmpty) {
            genresList.add(name);
          }
        }
      }
    }

    // Parse cast
    final castList = <CastMemberModel>[];
    final castRaw = json['cast'] as List<dynamic>? ?? [];
    for (final c in castRaw) {
      if (c is Map<String, dynamic>) {
        castList.add(CastMemberModel.fromJson(c));
      }
    }

    // Extract actor IDs from cast
    final actorIdsList = castList.map((c) => c.actorId).toList();

    return MovieModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'] as String)
          : null,
      duration: json['duration'] as int?,
      description: json['description'] as String? ?? '',
      genres: genresList,
      posterUrl: json['posterUrl'] as String?,
      posterBase64: json['posterBase64'] as String?,
      posterMimeType: json['posterMimeType'] as String?,
      ageRating: json['ageRating'] as String?,
      averageRating: _parseDouble(json['averageRating']),
      ratingsCount: _parseInt(json['ratingsCount']),
      directorId: json['directorId'] as String?,
      directorName: json['directorName'] as String?,
      cast: castList,
      actorIds: actorIdsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (releaseDate != null) 'releaseDate': releaseDate!.toIso8601String().split('T').first,
      if (duration != null) 'duration': duration,
      'description': description,
      'genreIds': genres,
      if (posterUrl != null) 'posterUrl': posterUrl,
      if (posterBase64 != null) 'posterBase64': posterBase64,
      if (posterMimeType != null) 'posterMimeType': posterMimeType,
      if (ageRating != null) 'ageRating': ageRating,
      if (averageRating != null) 'averageRating': averageRating,
      if (ratingsCount != null) 'ratingsCount': ratingsCount,
      if (directorId != null) 'directorId': directorId,
      if (directorName != null) 'directorName': directorName,
      'cast': cast.map((c) => c.toJson()).toList(),
    };
  }

  MovieModel copyWith({
    String? id,
    String? title,
    DateTime? releaseDate,
    int? duration,
    String? description,
    List<String>? genres,
    String? posterUrl,
    String? posterBase64,
    String? posterMimeType,
    String? ageRating,
    double? averageRating,
    int? ratingsCount,
    String? directorId,
    String? directorName,
    List<CastMemberModel>? cast,
    List<String>? actorIds,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      releaseDate: releaseDate ?? this.releaseDate,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      posterUrl: posterUrl ?? this.posterUrl,
      posterBase64: posterBase64 ?? this.posterBase64,
      posterMimeType: posterMimeType ?? this.posterMimeType,
      ageRating: ageRating ?? this.ageRating,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      directorId: directorId ?? this.directorId,
      directorName: directorName ?? this.directorName,
      cast: cast ?? this.cast,
      actorIds: actorIds ?? this.actorIds,
    );
  }

  String get formattedDuration {
    if (duration == null) return 'N/A';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}min';
    if (hours > 0) return '${hours}h';
    return '${minutes}min';
  }

  String get releaseYear => releaseDate?.year.toString() ?? 'N/A';

  String get formattedGenres => genres.join(', ');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}


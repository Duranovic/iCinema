class MovieScoreDto {
  final String movieId;
  final String title;
  final String? posterUrl;
  final List<String> genres;
  final String? director;
  final List<String> topActors;
  final double score;

  const MovieScoreDto({
    required this.movieId,
    required this.title,
    required this.posterUrl,
    required this.genres,
    required this.director,
    required this.topActors,
    required this.score,
  });

  factory MovieScoreDto.fromJson(Map<String, dynamic> json) {
    return MovieScoreDto(
      movieId: (json['movieId'] ?? '').toString(),
      title: (json['title'] ?? 'Nepoznat naslov').toString(),
      posterUrl: json['posterUrl'] as String?,
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
      director: json['director'] as String?,
      topActors: (json['topActors'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
      score: (json['score'] is num) ? (json['score'] as num).toDouble() : 0.0,
    );
  }
}

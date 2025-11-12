class Genre {
  final String id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Nepoznato',
    );
  }
}

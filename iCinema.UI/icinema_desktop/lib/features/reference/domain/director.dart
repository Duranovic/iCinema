class Director {
  final String id;
  final String fullName;
  final String? bio;
  final String? photoUrl;

  Director({
    required this.id,
    required this.fullName,
    this.bio,
    this.photoUrl,
  });

  factory Director.fromJson(Map<String, dynamic> json) {
    return Director(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Nepoznato',
      bio: json['bio']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
    );
  }
}

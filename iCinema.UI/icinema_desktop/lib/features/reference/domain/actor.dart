class Actor {
  final String id;
  final String fullName;
  final String? bio;
  final String? photoUrl;

  Actor({required this.id, required this.fullName, this.bio, this.photoUrl});

  factory Actor.fromJson(Map<String, dynamic> json) => Actor(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        bio: json['bio'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
}

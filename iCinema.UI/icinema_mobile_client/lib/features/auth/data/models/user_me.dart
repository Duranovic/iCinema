class UserMe {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;

  const UserMe({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
  });

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

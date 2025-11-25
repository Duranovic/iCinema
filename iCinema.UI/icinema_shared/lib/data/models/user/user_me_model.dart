/// Model representing the current authenticated user
class UserMeModel {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;

  const UserMeModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
  });

  /// Creates UserMeModel from JSON
  factory UserMeModel.fromJson(Map<String, dynamic> json) {
    return UserMeModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      roles: (json['roles'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// Converts UserMeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'roles': roles,
    };
  }

  /// Creates a copy with updated fields
  UserMeModel copyWith({
    String? id,
    String? email,
    String? fullName,
    List<String>? roles,
  }) {
    return UserMeModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roles: roles ?? this.roles,
    );
  }

  @override
  String toString() => 'UserMeModel(id: $id, email: $email, fullName: $fullName, roles: $roles)';
}


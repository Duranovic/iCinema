import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user
/// This is the domain representation, separate from data models
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String token;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  /// Creates UserEntity from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }

  /// Converts UserEntity to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'token': token,
      };

  /// Creates a copy with updated fields
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, name, email, token];

  @override
  String toString() => 'UserEntity(id: $id, name: $name, email: $email)';
}


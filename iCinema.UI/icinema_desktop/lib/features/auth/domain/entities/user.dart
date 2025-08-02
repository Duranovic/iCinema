import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user.
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }

  /// Converts this User instance to a map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'token': token,
  };

  @override
  List<Object?> get props => [id, name, email, token];
}

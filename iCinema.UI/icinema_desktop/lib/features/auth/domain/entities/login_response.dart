class LoginResponse {
  final String token;
  final DateTime expiresAt;

  LoginResponse({required this.token, required this.expiresAt});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}
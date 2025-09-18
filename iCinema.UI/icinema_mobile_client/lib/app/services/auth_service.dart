import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState extends ChangeNotifier {
  AuthState({
    required this.isAuthenticated,
    this.fullName,
    this.email,
    this.token,
  });

  bool isAuthenticated;
  String? fullName;
  String? email;
  String? token;

  AuthState copyWith({
    bool? isAuthenticated,
    String? fullName,
    String? email,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }
}

class AuthService {
  AuthService();

  static const _kTokenKey = 'auth_token';
  static const _kFullNameKey = 'auth_full_name';
  static const _kEmailKey = 'auth_email';

  final AuthState authState = AuthState(isAuthenticated: false);
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final token = _prefs!.getString(_kTokenKey);
    final name = _prefs!.getString(_kFullNameKey);
    final email = _prefs!.getString(_kEmailKey);
    if (token != null && token.isNotEmpty) {
      authState.isAuthenticated = true;
      authState.token = token;
      authState.fullName = name;
      authState.email = email;
    } else {
      authState.isAuthenticated = false;
    }
    authState.notifyListeners();
  }

  Future<void> setSession({
    required String token,
    String? fullName,
    String? email,
    DateTime? expiresAt, // reserved for future expiry validation
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_kTokenKey, token);
    if (fullName != null) {
      await _prefs!.setString(_kFullNameKey, fullName);
    }
    if (email != null) {
      await _prefs!.setString(_kEmailKey, email);
    }
    authState
      ..isAuthenticated = true
      ..token = token
      ..fullName = fullName ?? authState.fullName
      ..email = email ?? authState.email
      ..notifyListeners();
  }

  Future<void> logout() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_kTokenKey);
    await _prefs!.remove(_kFullNameKey);
    await _prefs!.remove(_kEmailKey);
    authState
      ..isAuthenticated = false
      ..token = null
      ..fullName = null
      ..email = null
      ..notifyListeners();
  }
}

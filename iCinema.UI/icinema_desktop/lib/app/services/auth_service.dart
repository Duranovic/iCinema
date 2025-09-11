import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthService {
  final ValueNotifier<bool> _loggedIn = ValueNotifier<bool>(false);
  
  // In-memory storage as fallback when SharedPreferences fails
  String? _token;
  DateTime? _expiresAt;
  
  // SharedPreferences for persistence (optional)
  SharedPreferences? _prefs;
  bool _initialized = false;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    try {
      print('AuthService: Initializing SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      print('AuthService: SharedPreferences initialized successfully');
      await _load();
    } catch (e) {
      print('AuthService: SharedPreferences initialization failed: $e');
      print('AuthService: Using in-memory storage as fallback');
      _loggedIn.value = false;
    }
    _initialized = true;
    print('AuthService: Initialization complete');
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _init();
    }
  }

  ValueListenable<bool> get authState => _loggedIn;

  String? get token {
    if (_prefs != null) {
      return _prefs!.getString('auth_token');
    }
    return _token; // Fallback to in-memory
  }

  DateTime? get expiresAt {
    if (_prefs != null) {
      final v = _prefs!.getString('auth_expiry');
      if (v != null) return DateTime.tryParse(v);
    }
    return _expiresAt; // Fallback to in-memory
  }

  Future<void> _load() async {
    if (_prefs == null) return;
    
    final hasToken = _prefs!.getString('auth_token') != null;
    final exp = expiresAt;
    final valid = hasToken && (exp == null || exp.isAfter(DateTime.now()));
    _loggedIn.value = valid;
    if (!valid) {
      await logout();
    }
  }

  Future<void> setSession({required String token, DateTime? expiresAt}) async {
    print('setSession called with token: ${token.substring(0, 10)}...');
    
    await _ensureInitialized();
    
    // Always store in memory as fallback
    _token = token;
    _expiresAt = expiresAt;
    print('Token stored in memory');
    
    // Try to persist to SharedPreferences if available
    if (_prefs != null) {
      try {
        await _prefs!.setString('auth_token', token);
        if (expiresAt != null) {
          await _prefs!.setString('auth_expiry', expiresAt.toIso8601String());
        } else {
          await _prefs!.remove('auth_expiry');
        }
        print('Token also saved to SharedPreferences');
      } catch (e) {
        print('Failed to save to SharedPreferences: $e');
      }
    } else {
      print('SharedPreferences not available, using in-memory storage only');
    }
    
    _loggedIn.value = true;
    print('Auth state set to true: ${_loggedIn.value}');
  }

  Future<void> logout() async {
    await _ensureInitialized();
    
    // Clear in-memory storage
    _token = null;
    _expiresAt = null;
    print('Cleared in-memory token storage');
    
    // Clear SharedPreferences if available
    if (_prefs != null) {
      try {
        await _prefs!.remove('auth_token');
        await _prefs!.remove('auth_expiry');
        print('Cleared SharedPreferences token storage');
      } catch (e) {
        print('Failed to clear SharedPreferences: $e');
      }
    }
    
    _loggedIn.value = false;
    print('Auth state set to false: ${_loggedIn.value}');
  }
}

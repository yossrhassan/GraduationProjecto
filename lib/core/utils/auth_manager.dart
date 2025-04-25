import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static String? _authToken;
  static final ValueNotifier<bool> authStateChanges = ValueNotifier<bool>(false);

  // Get the current token from memory
  static String? get authToken => _authToken;

  // Check if user is authenticated
  static bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  // Set token both in memory and persistent storage
static Future<void> setAuthToken(String token) async {
  _authToken = token;
  print('Auth token set in AuthManager: $_authToken');  // Add this print statement
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    authStateChanges.value = true;
  } catch (e) {
    print('Failed to save token to SharedPreferences: $e');
  }
}

static Future<void> loadAuthToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    print('Loaded auth token from SharedPreferences: $_authToken');  // Debug print
    authStateChanges.value = _authToken != null && _authToken!.isNotEmpty;
  } catch (e) {
    print('Failed to load token from SharedPreferences: $e');
  }
}

  // Clear token when logging out
  static Future<void> clearAuthToken() async {
    _authToken = null;
    authStateChanges.value = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      print('Failed to clear token from SharedPreferences: $e');
    }
  }


  Future<void> saveAuthToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
  print("Token saved: $token");
}
}

// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthManager {
//   static int? userId; // Add this line

//   static String? _authToken;
//   static final ValueNotifier<bool> authStateChanges =
//       ValueNotifier<bool>(false);

//   // Get the current token from memory
//   static String? get authToken => _authToken;

//   // Check if user is authenticated
//   static bool get isAuthenticated =>
//       _authToken != null && _authToken!.isNotEmpty;

//   // Set token both in memory and persistent storage
//   static Future<void> setAuthToken(String token) async {
//     _authToken = token;
//     print(
//         'Auth token set in AuthManager: $_authToken'); // Add this print statement
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('auth_token', token);
//       authStateChanges.value = true;
//     } catch (e) {
//       print('Failed to save token to SharedPreferences: $e');
//     }
//   }

//   static Future<void> loadAuthToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _authToken = prefs.getString('auth_token');
//       print(
//           'Loaded auth token from SharedPreferences: $_authToken'); // Debug print
//       authStateChanges.value = _authToken != null && _authToken!.isNotEmpty;
//     } catch (e) {
//       print('Failed to load token from SharedPreferences: $e');
//     }
//   }

//   // Clear token when logging out
//   static Future<void> clearAuthToken() async {
//     _authToken = null;
//     authStateChanges.value = false;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('auth_token');
//     } catch (e) {
//       print('Failed to clear token from SharedPreferences: $e');
//     }
//   }

//   Future<void> saveAuthToken(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('auth_token', token);
//     print("Token saved: $token");
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthManager {
  static int? userId; // In-memory cache
  static String? _authToken;
  static int? _userId;
  static final ValueNotifier<bool> authStateChanges =
      ValueNotifier<bool>(false);

  // Get the current token from memory
  static String? get authToken => _authToken;

  // Get the current user ID from memory
  static int? get userId {
    print('🔍 AuthManager.userId called, returning: $_userId');
    return _userId;
  }

  // Check if user is authenticated
  static bool get isAuthenticated =>
      _authToken != null && _authToken!.isNotEmpty;

  // Extract user ID from JWT token
  static int? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded);

      print('JWT Payload: $data');

      if (data['sub'] != null) {
        final userId = int.tryParse(data['sub'].toString());
        print('Extracted user ID from token: $userId');
        return userId;
      }
      return null;
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return null;
    }
  }

  // Set token both in memory and persistent storage
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    print(
        'Auth token set in AuthManager: $_authToken'); // Add this print statement

    // Extract and set user ID from token
    final userId = _extractUserIdFromToken(token);
    if (userId != null) {
      await setUserId(userId);
    }

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
      print(
          'Loaded auth token from SharedPreferences: $_authToken'); // Debug print

      // Extract and set user ID from loaded token
      if (_authToken != null) {
        final userId = _extractUserIdFromToken(_authToken!);
        if (userId != null) {
          await setUserId(userId);
        }
      }

      authStateChanges.value = _authToken != null && _authToken!.isNotEmpty;
    } catch (e) {
      print('Failed to load token from SharedPreferences: $e');
    }
  }

  // ✅ Clear token when logging out
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

  static Future<void> setUserId(int id) async {
    _userId = id;
    print('User ID set in AuthManager: $_userId');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', id);
      print('User ID saved to SharedPreferences: $id');
    } catch (e) {
      print('Failed to save user ID to SharedPreferences: $e');
    }
  }

  static Future<void> loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('user_id');
      print('Loaded user ID from SharedPreferences: $_userId');
    } catch (e) {
      print('Failed to load user ID from SharedPreferences: $e');
    }
  }

  static Future<void> clearUserId() async {
    _userId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      print('User ID cleared from SharedPreferences');
    } catch (e) {
      print('Failed to clear user ID from SharedPreferences: $e');
    }
  }

  // Clear all auth data when logging out
  static Future<void> clearAll() async {
    await clearAuthToken();
    await clearUserId();
    authStateChanges.value = false;
  }
}

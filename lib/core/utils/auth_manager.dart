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

class AuthManager {
  static int? userId; // In-memory cache
  static String? _authToken;
  static final ValueNotifier<bool> authStateChanges =
      ValueNotifier<bool>(false);

  // Get the current token from memory
  static String? get authToken => _authToken;

  // Check if user is authenticated
  static bool get isAuthenticated =>
      _authToken != null && _authToken!.isNotEmpty;

  // ✅ Set token both in memory and persistent storage
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    print('Auth token set in AuthManager: $_authToken');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      authStateChanges.value = true;
    } catch (e) {
      print('❌ Failed to save token to SharedPreferences: $e');
    }
  }

  // ✅ Load token from storage
  static Future<void> loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      print('✅ Loaded auth token: $_authToken');
      authStateChanges.value = _authToken != null && _authToken!.isNotEmpty;
    } catch (e) {
      print('❌ Failed to load token: $e');
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
      print('❌ Failed to clear token: $e');
    }
  }

  // ✅ Save user ID in memory and persistent storage
  static Future<void> setUserId(int id) async {
    userId = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', id);
      print('✅ User ID set in AuthManager: $userId');
    } catch (e) {
      print('❌ Failed to save userId: $e');
    }
  }

  // ✅ Load user ID from persistent storage
  static Future<void> loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
      print('✅ Loaded userId: $userId');
    } catch (e) {
      print('❌ Failed to load userId: $e');
    }
  }

  // ✅ Clear user ID
  static Future<void> clearUserId() async {
    userId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
    } catch (e) {
      print('❌ Failed to clear userId: $e');
    }
  }

  // (Optional legacy function)
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print("Token saved: $token");
  }
}

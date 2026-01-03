import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // TODO: Update this to your actual backend URL
  static const String baseUrl = 'http://ow0wk84w4sogcgs8g0s488wg.130.61.31.172.sslip.io';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _initialized = false;

  // Initialize Google Sign-In (required for google_sign_in 7.x)
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }
  }

  // Google Sign-In
  Future<AuthResult> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.signIn();
      if (googleUser == null) {
        return AuthResult.cancelled();
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return AuthResult.error('Failed to get ID token from Google');
      }

      // Send ID token to backend for verification
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['accessToken']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        return AuthResult.success(User.fromJson(data['user']));
      } else {
        return AuthResult.error('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // Traditional login with username/password
  Future<AuthResult> signInWithCredentials(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['accessToken']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        return AuthResult.success(User.fromJson(data['user']));
      } else {
        return AuthResult.error('Invalid credentials');
      }
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google sign out errors
    }
    await _storage.deleteAll();
  }

  // Get stored access token for API calls
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // Get current user from storage
  Future<User?> getCurrentUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Get auth headers for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

class AuthResult {
  final bool success;
  final bool cancelled;
  final String? error;
  final User? user;

  AuthResult._({
    required this.success,
    required this.cancelled,
    this.error,
    this.user,
  });

  factory AuthResult.success(User user) => AuthResult._(
        success: true,
        cancelled: false,
        user: user,
      );

  factory AuthResult.error(String message) => AuthResult._(
        success: false,
        cancelled: false,
        error: message,
      );

  factory AuthResult.cancelled() => AuthResult._(
        success: false,
        cancelled: true,
      );
}

class User {
  final int id;
  final String username;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? pictureUrl;
  final String? authority;
  final String? type;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.phoneNumber,
    this.pictureUrl,
    this.authority,
    this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      pictureUrl: json['pictureUrl'],
      authority: json['authority'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'pictureUrl': pictureUrl,
      'authority': authority,
      'type': type,
    };
  }
}

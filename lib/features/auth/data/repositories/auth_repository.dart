// lib/features/auth/data/repositories/auth_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/core/serivces/api_service.dart';
import 'package:to_do_list_app/features/auth/data/models/auth_model.dart';

class AuthRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<String> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );

      // Get auth token from API
      final response = await _apiService.getAuthToken(
          '/app/users/login', loginRequest.toJson());

      if (!response.isSuccess) {
        throw response.message;
      }

      // The token is directly returned as a string in the data field
      String token = response.data;
      await _saveToken(token);
      return token;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<AuthResponse> register(
      String username, String email, String password) async {
    try {
      final registerRequest = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );

      // Get auth token from API
      final response = await _apiService.getAuthToken(
          '/api/auth/register', registerRequest.toJson());

      if (!response.isSuccess) {
        throw response.message;
      }

      // The token is directly returned as a string in the data field
      String token = response.data;

      // Extract user info from token (assuming JWT)
      final user = await _getUserFromToken(token);

      // Create auth response
      final authResponse = AuthResponse(user: user, token: token);

      // Store auth data
      await _saveAuthData(authResponse);

      return authResponse;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      // Just do local logout - no need to send request to server if token-based auth
      await _clearAuthData();
    } catch (e) {
      // Still clear local auth data even if API call fails
      await _clearAuthData();
      throw e.toString();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson == null) {
        return null;
      }

      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authResponse.token);
    await prefs.setString('user', jsonEncode(authResponse.user.toJson()));
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Helper method to extract user info from JWT token
  Future<User> _getUserFromToken(String token) async {
    try {
      // This is a simplified approach to extract user info from JWT token
      // Remove 'Bearer ' prefix if present
      if (token.startsWith('Bearer ')) {
        token = token.substring(7);
      }

      // Split the token to get the payload part
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }

      // Decode the payload part (the second part of JWT)
      String payload = parts[1];

      // Add padding if needed
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      // Replace characters that are different in base64url and base64
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      // Decode the payload
      final normalized = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalized));
      final payloadJson = jsonDecode(decodedPayload);

      // Create user object from payload
      return User(
        id: payloadJson['id'] ?? '',
        username: payloadJson['usrname'] ??
            '', // Note: check if this matches your actual field name
        email: payloadJson['email'] ?? '',
        createdAt:
            DateTime.now(), // JWT usually doesn't include these timestamps
      );
    } catch (e) {
      print('Error extracting user info from token: $e');
      // Return a minimal user if extraction fails
      return User(
        id: '',
        username: '',
        email: '',
        createdAt: DateTime.now(),
      );
    }
  }
}

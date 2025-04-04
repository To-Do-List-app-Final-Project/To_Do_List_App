// lib/features/profiles/data/repositories/profile_repository.dart
import 'package:dio/dio.dart';
import 'package:to_do_list_app/features/todo/data/models/user_model.dart';

class ProfileRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8094',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Add auth token to requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final response = await _dio.put(
        '/users/profile',
        data: user.toJson(),
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/stats');

      return {
        'totalTasks': response.data['totalTasks'] ?? 0,
        'completedTasks': response.data['completedTasks'] ?? 0,
      };
    } catch (e) {
      // Return default values if stats can't be loaded
      return {
        'totalTasks': 0,
        'completedTasks': 0,
      };
    }
  }
}

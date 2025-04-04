// lib/features/profiles/data/repositories/profile_repository.dart
import 'package:dio/dio.dart';
import 'package:to_do_list_app/core/models/api_response.dart';
import 'package:to_do_list_app/core/serivces/api_service.dart';
import 'package:to_do_list_app/features/todo/data/models/response/user-profile.dart';
import 'package:to_do_list_app/features/todo/data/models/user_model.dart';

class ProfileRepository {
  final apiService = new ApiService();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8094',
    headers: {'Content-Type': 'application/json', 'Authorization': ''},
  ));

  // Add auth token to requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<ApiResponse> getUserProfile() async {
    try {
      final response = await apiService.get('/app/users/detail');
      final profile = ApiResponse<UserProfileResponse>.fromJson(
          response.data, (json) => UserProfileResponse.fromJson(json));
      return profile;
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

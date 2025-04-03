// lib/core/services/api_service.dart

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';

class ApiService extends GetxService {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl =
      'http://10.0.2.2:8094'; // Replace with actual API endpoint

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 30000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 30000);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for JWT token
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Continue request
        },
        onError: (dio.DioException e, handler) {
          if (e.response?.statusCode == 401) {
            _clearAuthData();
          }
          return handler.next(e); // Pass error down the pipeline
        },
      ),
    );
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    // Navigate to login or trigger logout event
  }

  // Generic GET method with response parsing
  Future<ApiResponse<T>> getWithParsing<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      return _handleErrorWithParsing<T>(e);
    }
  }

  // Generic POST method with response parsing
  Future<ApiResponse<T>> postWithParsing<T>(
    String path,
    dynamic data, {
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      return _handleErrorWithParsing<T>(e);
    }
  }

  // Generic PUT method with response parsing
  Future<ApiResponse<T>> putWithParsing<T>(
    String path,
    dynamic data, {
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      return _handleErrorWithParsing<T>(e);
    }
  }

  // Generic DELETE method with response parsing
  Future<ApiResponse<T>> deleteWithParsing<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.delete(path, data: data);
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      return _handleErrorWithParsing<T>(e);
    }
  }

  // Method to get auth token
  Future<StringApiResponse> getAuthToken(String path, dynamic data) async {
    try {
      final response = await _dio.post(path, data: data);
      if (response.statusCode != 200) {
        return StringApiResponse(
            status: response.statusCode ?? 500,
            message: 'Failed to get auth token',
            data: '');
      }
      if (response.data is Map<String, dynamic>) {
        final token = response.data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
      }
      return StringApiResponse.fromJson(response.data);
    } on dio.DioException catch (e) {
      return _createErrorStringResponse(e);
    }
  }

  // Legacy methods for backward compatibility
  Future<dio.Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _requestWrapper(
        () => _dio.get(path, queryParameters: queryParameters));
  }

  Future<dio.Response> post(String path, dynamic data) async {
    return _requestWrapper(() => _dio.post(path, data: data));
  }

  Future<dio.Response> put(String path, dynamic data) async {
    return _requestWrapper(() => _dio.put(path, data: data));
  }

  Future<dio.Response> delete(String path, {dynamic data}) async {
    return _requestWrapper(() => _dio.delete(path, data: data));
  }

  // Wrapper for error handling
  Future<dio.Response> _requestWrapper(
      Future<dio.Response> Function() request) async {
    try {
      return await request();
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling for parsed responses
  ApiResponse<T> _handleErrorWithParsing<T>(dio.DioException error) {
    final (message, status) = _extractErrorDetails(error);
    return ApiResponse.error(message, statusCode: status);
  }

  // Error handling for string responses
  StringApiResponse _createErrorStringResponse(dio.DioException error) {
    final (message, status) = _extractErrorDetails(error);
    return StringApiResponse(status: status, message: message, data: '');
  }

  // Extract error details
  (String, int) _extractErrorDetails(dio.DioException error) {
    String errorMessage = 'Something went wrong';
    int statusCode = 500;

    if (error.response != null) {
      statusCode = error.response!.statusCode ?? 500;
      if (error.response!.data is Map<String, dynamic>) {
        errorMessage = error.response!.data['message'] ?? errorMessage;
      } else if (error.response!.data is String) {
        errorMessage = error.response!.data;
      }
    } else {
      errorMessage = error.message ?? errorMessage;
    }

    return (errorMessage, statusCode);
  }

  // Generic error handler
  dio.DioException _handleError(dio.DioException error) {
    print('Error: ${error.message}');
    return error;
  }
}

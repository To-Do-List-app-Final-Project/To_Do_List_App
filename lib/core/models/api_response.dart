// lib/core/models/api_response.dart

import 'package:to_do_list_app/features/auth/data/models/auth_model.dart';

class ApiResponse<T> {
  final int status;
  final String message;
  final T data;
  final bool? _fwList;
  final bool? _fwConsroller;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
    bool? fwList,
    bool? fwConsroller,
  })  : _fwList = fwList,
        _fwConsroller = fwConsroller;

  bool get isSuccess => status >= 200 && status < 300;
  bool get isFwList => _fwList ?? false;
  bool get isFwConsroller => _fwConsroller ?? false;

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: fromJsonT(json['data']),
      fwList: json['_fw_list'],
      fwConsroller: json['_fw_consoller'],
    );
  }

  factory ApiResponse.error(String errorMessage, {int statusCode = 500}) {
    return ApiResponse<T>(
      status: statusCode,
      message: errorMessage,
      data: null as T,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    final Map<String, dynamic> json = {
      'status': status,
      'message': message,
      'data': toJsonT(data),
    };

    if (_fwList != null) json['_fw_list'] = _fwList;
    if (_fwConsroller != null) json['_fw_consoller'] = _fwConsroller;

    return json;
  }
}

// Specialization for string responses (like your token example)
class StringApiResponse extends ApiResponse<String> {
  StringApiResponse({
    required int status,
    required String message,
    required String data,
    bool? fwList,
    bool? fwConsroller,
  }) : super(
          status: status,
          message: message,
          data: data,
          fwList: fwList,
          fwConsroller: fwConsroller,
        );

  factory StringApiResponse.fromJson(Map<String, dynamic> json) {
    return StringApiResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] ?? '',
      fwList: json['_fw_list'],
      fwConsroller: json['_fw_consoller'],
    );
  }
}

// Specialization for list responses
class ListApiResponse<T> extends ApiResponse<List<T>> {
  ListApiResponse({
    required int status,
    required String message,
    required List<T> data,
    bool? fwList,
    bool? fwConsroller,
  }) : super(
          status: status,
          message: message,
          data: data,
          fwList: fwList,
          fwConsroller: fwConsroller,
        );

  factory ListApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    final List<dynamic> dataList = json['data'] is List ? json['data'] : [];
    return ListApiResponse<T>(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: dataList.map((item) => fromJsonT(item)).toList(),
      fwList: json['_fw_list'],
      fwConsroller: json['_fw_consoller'],
    );
  }
}

// Example of a model-specific API response for User data
class UserApiResponse extends ApiResponse<User> {
  UserApiResponse({
    required int status,
    required String message,
    required User data,
    bool? fwList,
    bool? fwConsroller,
  }) : super(
          status: status,
          message: message,
          data: data,
          fwList: fwList,
          fwConsroller: fwConsroller,
        );

  factory UserApiResponse.fromJson(Map<String, dynamic> json) {
    return UserApiResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: User.fromJson(json['data']),
      fwList: json['_fw_list'],
      fwConsroller: json['_fw_consoller'],
    );
  }
}

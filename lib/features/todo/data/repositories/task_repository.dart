// lib/features/todo/data/repositories/task_repository.dart

import 'package:get/get.dart';
import 'package:to_do_list_app/core/models/api_list_response.dart';
import 'package:to_do_list_app/core/serivces/api_service.dart';
import 'package:to_do_list_app/features/todo/data/models/tasks_model.dart';

class TaskRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Task>> getTasks(
      {int pageSize = 10, int pageNo = 1, String? categoryId}) async {
    try {
      Map<String, dynamic> queryParams = {
        'pageSize': pageSize,
        'pageNo': pageNo,
      };

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response =
          await _apiService.get('/app/tasks', queryParameters: queryParams);

      final apiResponse = APIListResponse<Task>.fromJson(
        response.data,
        (json) => Task.fromJson(json),
      );
      if (!apiResponse.isSuccess) {
        print('Error fetching cars: ${apiResponse.message}');
        throw Exception(apiResponse.message);
      }
      // Return the list of cars
      return apiResponse.data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Task> getTaskById(String id) async {
    try {
      final response = await _apiService.get('/api/tasks/$id');
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await _apiService.post('/app/tasks', task.toJson());
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response =
          await _apiService.put('/app/tasks/${task.id}', task.toJson());
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _apiService.delete('/app/tasks/$id');
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> toggleTaskStatus(String id) async {
    try {
      await _apiService.put('/app/tasks/$id/toggle', {});
      return true;
    } catch (e) {
      throw e.toString();
    }
  }
}

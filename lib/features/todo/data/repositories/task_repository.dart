// lib/features/todo/data/repositories/task_repository.dart

import 'package:get/get.dart';
import 'package:dio/dio.dart';
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
          await _apiService.get('/api/tasks', queryParameters: queryParams);

      final List<dynamic> data = response.data['data'];
      return data.map((item) => Task.fromJson(item)).toList();
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
      final response = await _apiService.post('/api/tasks', task.toJson());
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response =
          await _apiService.put('/api/tasks/${task.id}', task.toJson());
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _apiService.delete('/api/tasks/$id');
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> toggleTaskStatus(String id) async {
    try {
      await _apiService.put('/api/tasks/$id/toggle', {});
      return true;
    } catch (e) {
      throw e.toString();
    }
  }
}

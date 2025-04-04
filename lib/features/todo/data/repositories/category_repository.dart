// lib/features/todo/data/repositories/category_repository.dart

import 'package:get/get.dart';
import 'package:to_do_list_app/core/models/api_list_response.dart';
import 'package:to_do_list_app/core/serivces/api_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get('/app/categories');

      final List<dynamic> data = response.data['data'];
      final apiResponse = APIListResponse<Category>.fromJson(
        response.data,
        (json) => Category.fromJson(json),
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

  Future<Category> getCategoryById(String id) async {
    try {
      final response = await _apiService.get('/api/categories/$id');
      return Category.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Category> createCategory(Category category) async {
    try {
      final response =
          await _apiService.post('/app/categories', category.toJson());
      return Category.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Category> updateCategory(Category category) async {
    try {
      final response = await _apiService.put(
          '/api/categories/${category.id}', category.toJson());
      return Category.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _apiService.delete('/api/categories/$id');
      return true;
    } catch (e) {
      throw e.toString();
    }
  }
}

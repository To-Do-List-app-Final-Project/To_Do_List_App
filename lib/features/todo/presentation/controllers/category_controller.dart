// lib/features/todo/presentation/controllers/category_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repository = CategoryRepository();

  // Observable state variables
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      error.value = '';

      final fetchedCategories = await _repository.getCategories();
      categories.value = fetchedCategories;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory(String title, Color color) async {
    try {
      isLoading.value = true;
      error.value = '';

      final newCategory = Category(
        id: '', // Will be assigned by server
        title: title,
        color: Category.colorToString(color),
      );

      final createdCategory = await _repository.createCategory(newCategory);
      categories.add(createdCategory);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedCategory = await _repository.updateCategory(category);

      final index = categories.indexWhere((c) => c.id == updatedCategory.id);
      if (index != -1) {
        categories[index] = updatedCategory;
        categories
            .refresh(); // Important to notify observers of the list change
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _repository.deleteCategory(id);

      if (success) {
        categories.removeWhere((category) => category.id == id);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Method to get category by ID (from local list)
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

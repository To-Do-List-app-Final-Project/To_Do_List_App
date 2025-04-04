// lib/features/profiles/presentation/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/data/models/user_model.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/category_page.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  // Create repository instance directly
  final ProfileRepository repository = ProfileRepository();

  // Observable state variables
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxInt taskCount = 0.obs;
  final RxInt completedTaskCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userData = await repository.getUserProfile();
      final user = UserModel.fromJson({
        'id': userData.data.id,
        'username': userData.data.username,
        'email': userData.data.email,
      });
      this.user.value = user;
      error.value = "";
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;
      error.value = '';

      final result = await repository.updateUserProfile(updatedUser);
      user.value = result;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  double get completionRate {
    if (taskCount.value == 0) return 0.0;
    return completedTaskCount.value / taskCount.value;
  }

  void navigateToEditProfile() {
    if (user.value == null) return;
    Get.toNamed('/edit-profile', arguments: user.value);
  }

  void navigateToCategoryScreen() {
    Get.to(EditCategoryPage());
  }
}

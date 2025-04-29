// lib/features/auth/presentation/controllers/auth_controller.dart

import 'package:get/get.dart';
import 'package:to_do_list_app/features/auth/data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  // Observable state variables
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isLoggedIn = true.obs;
  final RxString tempAuthToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;

      // Check if user is logged inn
      isLoggedIn.value = await _repository.isLoggedIn();

      if (isLoggedIn.value) {
        user.value = await _repository.getCurrentUser();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      String authResponse = await _repository.login(email, password);
      isLoggedIn.value = true;
      tempAuthToken.value = authResponse;

      // Navigate to home page or dashboard
      Get.offAllNamed('/main');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _repository.register(username, email, password);

      // Navigate to home page or dashboard
      Get.offAllNamed('/login');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';

      await _repository.logout();

      user.value = null;
      isLoggedIn.value = false;

      // Navigate to login page
      Get.offAllNamed('/login');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile
  Future<void> updateProfile(String username, String email) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Implement profile update logic here
      // This would require additional API endpoint
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Implement password reset logic here
      // This would require additional API endpoint
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

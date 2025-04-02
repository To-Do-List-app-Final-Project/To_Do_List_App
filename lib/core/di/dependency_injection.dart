// lib/core/di/dependency_injection.dart

import 'package:get/get.dart';
import 'package:to_do_list_app/core/serivces/api_service.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/todo/presentation/controllers/task_controller.dart';
import '../../features/todo/presentation/controllers/category_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Core services
    Get.put<ApiService>(ApiService(), permanent: true);

    // Auth
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Tasks
    Get.lazyPut<TaskController>(() => TaskController(), fenix: true);

    // Categories
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
  }
}

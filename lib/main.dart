// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/core/di/dependency_injection.dart';
import 'package:to_do_list_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:to_do_list_app/features/auth/presentation/pages/log_page.dart';
import 'package:to_do_list_app/features/auth/presentation/pages/signup_page.dart';
import 'package:to_do_list_app/features/todo/presentation/controllers/task_controller.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/home_page.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/main_screen.dart';
import 'package:to_do_list_app/core/theme/theme_controller.dart';
import 'package:to_do_list_app/core/theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();

  // Initialize theme controller
  Get.put(ThemeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Todo List App',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeController.themeMode.value,
          initialRoute: '/login',
          getPages: [
            GetPage(name: '/', page: () => SplashScreen()),
            GetPage(name: '/login', page: () => LoginPage()),
            GetPage(name: '/signup', page: () => SignupPage()),
            GetPage(name: '/main', page: () => MainScreen()),
            GetPage(name: '/home', page: () => HomePage()),
            // GetPage(name: '/task-detail/:id', page: () => TaskDetailPage()),
            // GetPage(name: '/edit-category', page: () => EditCategoryPage()),
          ],
        ));
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    taskController.fetchTasks();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Show splash for 2 seconds

    if (authController.isLoggedIn.value) {
      Get.offAllNamed('/login');
    } else {
      Get.offAllNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const Text(
              'Todo List App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

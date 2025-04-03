// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/core/di/dependency_injection.dart';
import 'package:to_do_list_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:to_do_list_app/features/auth/presentation/pages/log_page.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/home_page.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Todo List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/main', page: () => MainScreen()),
        GetPage(name: '/home', page: () => HomePage()),
        // GetPage(name: '/task-detail/:id', page: () => TaskDetailPage()),
        // GetPage(name: '/edit-category', page: () => EditCategoryPage()),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Show splash for 2 seconds

    if (authController.isLoggedIn.value) {
      Get.offAllNamed('/main');
    } else {
      Get.offAllNamed('/login');
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

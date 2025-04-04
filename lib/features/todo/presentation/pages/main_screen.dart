// lib/features/main/presentation/pages/main_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:to_do_list_app/features/todo/presentation/controllers/profile_controller.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/calender_page.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/home_page.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/profile_screen.dart';
import '../widgets/bottom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const routeName = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // Get controllers instances
  final AuthController _authController = Get.find<AuthController>();
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();

    // Initialize ProfileController
    _profileController = Get.put(ProfileController());

    _loadProfileData();
    _setupAuthListener();
  }

  void _loadProfileData() {
    // Load profile data when screen initializes
    _profileController.loadProfile();
  }

  void _setupAuthListener() {
    // Monitor authentication status changes
    ever(_authController.isLoggedIn, (isLoggedIn) {
      if (!isLoggedIn) {
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const CalendarPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}

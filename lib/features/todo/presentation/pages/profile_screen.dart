// lib/features/profiles/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/presentation/pages/profile_content.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the controller instance that was created in MainScreen
    final controller = Get.find<ProfileController>();

    return Obx(() {
      // Show error if there is one
      if (controller.error.value.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: const Color(0xFFF6F6F6),
            foregroundColor: Colors.black,
          ),
          body: Center(child: Text('Error: ${controller.error.value}')),
        );
      }

      // Show profile if loaded
      if (controller.user.value != null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: const Color(0xFFF6F6F6),
            foregroundColor: Colors.black,
          ),
          body: SafeArea(
            child: ProfileContent(user: controller.user.value!),
          ),
        );
      }

      // Fallback - show loading
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    });
  }
}

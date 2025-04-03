// lib/features/profiles/presentation/pages/profile_content.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/data/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileContent extends StatelessWidget {
  final UserModel user;

  const ProfileContent({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final profileController = Get.find<ProfileController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Profile Card
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () => profileController.navigateToEditProfile(),
                ),
              ],
            ),
          ),

          // Task Stats Card
          Obx(() {
            final completed = profileController.completedTaskCount.value;
            final total = profileController.taskCount.value;
            final completionPercent =
                total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Completion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total', total.toString()),
                      _buildStatItem('Completed', completed.toString()),
                      _buildStatItem('Completion', '$completionPercent%'),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Settings Section
          _buildSettingsCard([
            _buildTile(
              context,
              Icons.category_outlined,
              'Categories',
              onTap: () => profileController.navigateToCategoryScreen(),
            ),
            _buildTile(
              context,
              Icons.dark_mode_outlined,
              'Dark Mode',
              trailing: Switch(
                value: false,
                onChanged: (_) {
                  // Toggle theme
                },
              ),
            ),
            _buildTile(
              context,
              Icons.language,
              'Language',
              onTap: () => _showLanguageSelector(context),
            ),
          ]),

          const SizedBox(height: 16),

          // Logout Section
          _buildSettingsCard([
            _buildTile(
              context,
              Icons.description_outlined,
              'Terms & Conditions',
              onTap: () {
                // Navigate to terms
              },
            ),
            _buildTile(
              context,
              Icons.logout,
              'Logout',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () => _showLogoutConfirmation(context, authController),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blue),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(
      BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () {
              Get.back();
              authController.logout();
            },
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) => ListTile(
                  title: Text(lang),
                  onTap: () {
                    // Apply language selection
                    Get.back();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> tiles) {
    return Container(
      decoration: _boxDecoration(),
      child: Column(
        children: List.generate(
          tiles.length * 2 - 1,
          (i) => i.isEven ? tiles[i ~/ 2] : const Divider(height: 1),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

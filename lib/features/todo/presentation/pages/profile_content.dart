// lib/features/profiles/presentation/pages/profile_content.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/data/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:to_do_list_app/core/theme/theme_controller.dart';

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
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Profile Card
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(context),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      AssetImage('assets/images/profile_avatar.png'),
                  onBackgroundImageError: (_, __) {
                    // Handle image loading error
                  },
                  child: Image.asset(
                    'assets/images/profile_avatar.png',
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 32, color: Colors.grey);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
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
              decoration: _boxDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Completion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(context, 'Total', total.toString()),
                      _buildStatItem(
                          context, 'Completed', completed.toString()),
                      _buildStatItem(
                          context, 'Completion', '$completionPercent%'),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Settings Section
          _buildSettingsCard(context, [
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
              trailing: Obx(() => Switch(
                    value: themeController.isDarkMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      themeController.changeThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                    },
                  )),
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
          _buildSettingsCard(context, [
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

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    final actualIconColor = iconColor ?? Theme.of(context).colorScheme.primary;
    final actualTextColor =
        textColor ?? Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: actualIconColor),
      title: Text(
        title,
        style: TextStyle(color: actualTextColor),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(
      BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Confirm Logout',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: () {
              Get.back();
              authController.logout();
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      barrierDismissible: true,
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) => ListTile(
                  title: Text(
                    lang,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
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

  Widget _buildSettingsCard(BuildContext context, List<Widget> tiles) {
    return Container(
      decoration: _boxDecoration(context),
      child: Column(
        children: List.generate(
          tiles.length * 2 - 1,
          (i) => i.isEven
              ? tiles[i ~/ 2]
              : Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor.withOpacity(
              Theme.of(context).brightness == Brightness.light ? 0.03 : 0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

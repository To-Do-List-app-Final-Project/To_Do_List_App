// lib/core/widgets/theme_toggle_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/core/theme/theme_controller.dart';

class ThemeToggleWidget extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => IconButton(
          icon: Icon(
            themeController.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: themeController.isDarkMode ? Colors.amber : Colors.blueGrey,
          ),
          onPressed: () => themeController.toggleTheme(),
          tooltip: themeController.isDarkMode
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
        ));
  }
}

// Alternative implementation with a Switch
class ThemeSwitchWidget extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.light_mode_rounded,
              size: 20,
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            Switch(
              value: themeController.isDarkMode,
              onChanged: (value) {
                themeController
                    .changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            Icon(
              Icons.dark_mode_rounded,
              size: 20,
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ],
        ));
  }
}

// Alternative implementation with a SegmentedButton (Material 3)
class ThemeModeSelector extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      ThemeMode currentMode = themeController.themeMode.value;

      return SegmentedButton<ThemeMode>(
        segments: [
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
            label: Text('Light'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto),
            label: Text('Auto'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
            label: Text('Dark'),
          ),
        ],
        selected: {currentMode},
        onSelectionChanged: (Set<ThemeMode> newSelection) {
          themeController.changeThemeMode(newSelection.first);
        },
      );
    });
  }
}

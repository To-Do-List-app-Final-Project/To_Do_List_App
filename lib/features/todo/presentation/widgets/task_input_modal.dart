import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/data/models/category_model.dart';
import 'package:to_do_list_app/features/todo/data/models/tasks_model.dart';
import 'package:to_do_list_app/features/todo/presentation/controllers/category_controller.dart';
import 'package:to_do_list_app/features/todo/presentation/controllers/task_controller.dart';
import 'date_picker_modal.dart';
import 'option_button.dart';
import 'reminder_dialog.dart';
import 'date_time_utils.dart';

/// Controller to manage task input state
class TaskInputController extends GetxController {
  final TaskController taskController = Get.find<TaskController>();

  final textController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observable variables
  final dateButtonText = 'Today'.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);
  final Rx<List<DateTime>?> multipleDates = Rx<List<DateTime>?>(null);
  final Rx<Map<String, dynamic>?> repeatConfig =
      Rx<Map<String, dynamic>?>(null);
  final dateMode = 'normal'.obs;
  final priority = 'Medium'.obs;

  final Rx<DateTime?> reminderDateTime = Rx<DateTime?>(null);
  final reminderText = 'Add Reminder'.obs;
  final Rx<Category?> selectedCategory = Rx<Category?>(null);

  // For category
  final category = ''.obs;
  final categoryId = ''.obs;
  final isSubmitting = false.obs;

  void init(String categoryName, String catId) {
    category.value = categoryName;
    categoryId.value = catId;
  }

  Color getCategoryColor(String categoryId) {
    // Try to find the category in the task controller
    final categoryController = Get.find<CategoryController>();
    if (categoryController != null) {
      final category = categoryController.getCategoryById(categoryId);
      if (category != null) {
        return category.colorValue;
      }
    }

    // Fallback color mapping
    switch (category.value.toLowerCase()) {
      case 'work':
        return Colors.blue[200]!;
      case 'personal':
        return Colors.green[200]!;
      case 'shopping':
        return Colors.orange[200]!;
      default:
        return Colors.purple[200]!;
    }
  }

  void updateDateSelection(DateSelectionResult result) {
    dateMode.value = result.mode;
    dateButtonText.value = result.displayText;

    // Store the appropriate date value based on mode
    switch (result.mode) {
      case 'normal':
        selectedDate.value = result.singleDate ?? DateTime.now();
        dateRange.value = null;
        multipleDates.value = null;
        repeatConfig.value = null;
        break;
      case 'period':
        dateRange.value = result.dateRange;
        multipleDates.value = null;
        repeatConfig.value = null;
        break;
      case 'multiple':
        dateRange.value = null;
        multipleDates.value = result.multipleDates;
        repeatConfig.value = null;
        break;
      case 'repeat':
        selectedDate.value = result.singleDate ?? DateTime.now();
        repeatConfig.value = result.repeatConfig;
        break;
    }
  }

  void updateReminderDateTime(DateTime? dateTime, BuildContext context) {
    reminderDateTime.value = dateTime;

    if (dateTime == null) {
      reminderText.value = 'Add Reminder';
      return;
    }

    // Format the reminder text
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      // Today
      final timeStr = TimeOfDay.fromDateTime(dateTime).format(context);
      reminderText.value = "Today, $timeStr";
    } else if (dateTime.day == tomorrow.day &&
        dateTime.month == tomorrow.month &&
        dateTime.year == tomorrow.year) {
      // Tomorrow
      final timeStr = TimeOfDay.fromDateTime(dateTime).format(context);
      reminderText.value = "Tomorrow, $timeStr";
    } else {
      // Other date
      final dateStr = "${dateTime.month}/${dateTime.day}";
      final timeStr = TimeOfDay.fromDateTime(dateTime).format(context);
      reminderText.value = "$dateStr, $timeStr";
    }
  }

  // Create the task
  Future<bool> createTask() async {
    if (textController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a task title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return false;
    }

    try {
      isSubmitting.value = true;

      await taskController.createTask(
        title: textController.text.trim(),
        description: descriptionController.text.trim(),
        priority: priority.value,
        categoryId: categoryId.value,
        scheduleDate: selectedDate.value.toIso8601String(),
        reminderDate: reminderDateTime.value,
        status: "Pending",
        repeat: "Daily",
      );

      Get.snackbar(
        'Success',
        'Task added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

void showTaskInputModal(
    BuildContext context, String category, String categoryId) {
  // Initialize controller
  final controller = Get.put(TaskInputController());

  // Set initial category
  controller.init(category, categoryId);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface, // Theme color
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.textController,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Please enter what to do',
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
              ),
            ),
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Add description (optional)',
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 14,
                ),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Obx(() => GestureDetector(
                              onTap: () {
                                // Show calendar date picker
                                showDatePickerModal(
                                  context,
                                  initialDate: controller.selectedDate.value,
                                  initialMode: controller.dateMode.value,
                                  onDateSelected:
                                      controller.updateDateSelection,
                                  taskTitle: controller.textController.text,
                                );
                              },
                              child: OptionButton(
                                icon: Icons.calendar_today,
                                label: controller.dateButtonText.value,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )),
                        const SizedBox(width: 6),
                        Obx(() => OptionButton(
                              icon: Icons.notifications_none,
                              label: controller.reminderText.value,
                              color: controller.reminderDateTime.value != null
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.transparent,
                              iconSize: 20,
                              onTap: () {
                                final taskTitle =
                                    controller.textController.text;
                                showReminderDialog(context, taskTitle)
                                    .then((result) {
                                  if (Get.isRegistered<TaskInputController>()) {
                                    controller.updateReminderDateTime(
                                        result, context);
                                  }
                                });
                              },
                            )),
                        const SizedBox(width: 8),
                        Obx(() => OptionButton(
                              icon: Icons.description_outlined,
                              label: controller.category.value,
                              color: controller.getCategoryColor(
                                  controller.categoryId.value),
                            )),
                        const SizedBox(width: 8),
                        Obx(() => OptionButton(
                              icon: Icons.flag_outlined,
                              label: controller.priority.value,
                              color: controller.priority.value == 'High'
                                  ? Theme.of(context).colorScheme.error
                                  : controller.priority.value == 'Medium'
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.7)
                                      : Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.7),
                              onTap: () {
                                if (controller.priority.value == 'High') {
                                  controller.priority.value = 'Medium';
                                } else if (controller.priority.value ==
                                    'Medium') {
                                  controller.priority.value = 'Low';
                                } else {
                                  controller.priority.value = 'High';
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => controller.isSubmitting.value
                      ? const CircularProgressIndicator()
                      : CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          radius: 24,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () async {
                              final success = await controller.createTask();
                              await controller.taskController
                                  .fetchTasks(); // Fetch tasks after creation
                              if (success) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ).then((_) {
    Get.delete<TaskInputController>();
  });
}

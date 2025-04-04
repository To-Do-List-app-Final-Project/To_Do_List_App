import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/data/models/tasks_model.dart';
import 'package:to_do_list_app/features/todo/presentation/controllers/task_controller.dart';
import 'date_picker_modal.dart';
import 'option_button.dart';
import 'reminder_dialog.dart';
import 'date_time_utils.dart';

// Controller to manage task input state
class TaskInputController extends GetxController {
  final TaskController taskController = Get.find<TaskController>();

  final textController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observable variables
  final dateButtonText = 'Today'.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);
  final Rx<List<DateTime>?> multipleDates = Rx<List<DateTime>?>(null);
  final Rx<Map<String, dynamic>?> repeatConfig =
      Rx<Map<String, dynamic>?>(null);
  final dateMode = 'normal'.obs;

  final Rx<DateTime?> reminderDateTime = Rx<DateTime?>(null);
  final reminderText = ''.obs;

  // For category
  final category = ''.obs;
  final categoryId = ''.obs;

  void init(String categoryName, String catId) {
    category.value = categoryName;
    categoryId.value = catId;
  }

  void updateDateSelection(DateSelectionResult result) {
    dateMode.value = result.mode;
    dateButtonText.value = result.displayText;

    // Store the appropriate date value based on mode
    switch (result.mode) {
      case 'normal':
        selectedDate.value = result.singleDate;
        dateRange.value = null;
        multipleDates.value = null;
        repeatConfig.value = null;
        break;
      case 'period':
        selectedDate.value = null;
        dateRange.value = result.dateRange;
        multipleDates.value = null;
        repeatConfig.value = null;
        break;
      case 'multiple':
        selectedDate.value = null;
        dateRange.value = null;
        multipleDates.value = result.multipleDates;
        repeatConfig.value = null;
        break;
      case 'repeat':
        selectedDate.value = result.singleDate;
        dateRange.value = null;
        multipleDates.value = null;
        repeatConfig.value = result.repeatConfig;
        break;
    }
  }

  void updateReminderDateTime(DateTime? dateTime, BuildContext context) {
    if (dateTime == null) return;

    reminderDateTime.value = dateTime;

    // Format the reminder text
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      // Today
      final timeStr = TimeOfDay.fromDateTime(dateTime).format(context);
      reminderText.value = timeStr;
    } else if (dateTime.day == tomorrow.day &&
        dateTime.month == tomorrow.month &&
        dateTime.year == tomorrow.year) {
      // Tomorrow
      final timeStr = TimeOfDay.fromDateTime(dateTime).format(context);
      reminderText.value = "$timeStr";
    } else {
      // Other date
      final dateStr = "${dateTime.month}/${dateTime.day}";
      final timeStr = TimeOfDay.fromDateTime(dateTime).format(context);
      reminderText.value = "$dateStr, $timeStr";
    }
  }

  Color getCategoryColor(String categoryName) {
    // Implement your category color logic here
    switch (categoryName.toLowerCase()) {
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

  Future<bool> createTask() async {
    if (textController.text.isEmpty) {
      return false;
    }

    try {
      // Log task data being created
      _logTaskData(
          textController.text, descriptionController.text, categoryId.value);

      // Create task using your controller's method
      await taskController.createTask(
          textController.text, descriptionController.text, categoryId.value);

      print('✅ TASK CREATED SUCCESSFULLY');
      return true;
    } catch (e) {
      print('❌ ERROR CREATING TASK: $e');
      return false;
    }
  }

  void _logTaskData(String title, String description, String categoryId) {
    print('\n');
    print('📝 =============== TASK DATA BEING SENT TO API ===============');
    print('📌 Task Title: $title');
    print('📝 Description: $description');
    print('🏷️ Category ID: $categoryId');
    print('📅 Created Date: ${DateTime.now().toIso8601String()}');

    // Log date-related information based on the selected mode
    print('🗓️ Date Mode: ${dateMode.value}');
    switch (dateMode.value) {
      case 'normal':
        print(
            '📆 Schedule Date: ${selectedDate.value?.toIso8601String() ?? "Today"}');
        break;
      case 'period':
        if (dateRange.value != null) {
          print('📆 Start Date: ${dateRange.value!.start.toIso8601String()}');
          print('📆 End Date: ${dateRange.value!.end.toIso8601String()}');
        }
        break;
      case 'multiple':
        if (multipleDates.value != null && multipleDates.value!.isNotEmpty) {
          print('📆 Multiple Dates (${multipleDates.value!.length}):');
          for (var date in multipleDates.value!) {
            print('  - ${date.toIso8601String()}');
          }
        }
        break;
      case 'repeat':
        print(
            '📆 Repeat Start Date: ${selectedDate.value?.toIso8601String() ?? "Today"}');
        if (repeatConfig.value != null) {
          print('🔄 Repeat Type: ${repeatConfig.value!["frequency"]}');
          print('🔄 Repeat Interval: ${repeatConfig.value!["interval"]}');
        }
        break;
    }

    if (reminderDateTime.value != null) {
      print('⏰ Reminder: ${reminderDateTime.value!.toIso8601String()}');
    }

    print('✅ Is Completed: false');
    print('==============================================================\n');
  }

  @override
  void onClose() {
    textController.dispose();
    descriptionController.dispose();
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
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                  color: Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Add description (optional)',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => GestureDetector(
                          onTap: () {
                            // Show calendar date picker
                            showDatePickerModal(
                              context,
                              initialDate: controller.selectedDate.value,
                              initialMode: controller.dateMode.value,
                              onDateSelected: controller.updateDateSelection,
                            );
                          },
                          child: OptionButton(
                            icon: Icons.calendar_today,
                            label: controller.dateButtonText.value,
                            color: Colors.blue[200]!,
                          ),
                        )),
                    SizedBox(width: 6),
                    Obx(() => OptionButton(
                          icon: Icons.notifications_none,
                          label: controller.reminderText.value,
                          color: controller.reminderDateTime.value != null
                              ? Colors.blue[200]!
                              : Colors.transparent,
                          iconSize: 20, // Larger notification icon
                          onTap: () {
                            // Pass the text controller to the reminder dialog
                            showReminderDialog(
                                    context, controller.textController)
                                .then((result) {
                              if (result != null) {
                                controller.updateReminderDateTime(
                                    result, context);
                              }
                            });
                          },
                        )),
                    SizedBox(width: 8),
                    Obx(() => OptionButton(
                          icon: Icons.description_outlined,
                          label: controller.category.value,
                          color: controller
                              .getCategoryColor(controller.category.value),
                        )),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.blue[300],
                  radius: 24,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      // Check if task has a title
                      if (controller.textController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please enter a task title',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: EdgeInsets.all(16),
                          borderRadius: 8,
                        );
                        return;
                      }

                      // Show loading indicator
                      Get.dialog(
                        Center(child: CircularProgressIndicator()),
                        barrierDismissible: false,
                      );

                      final success = await controller.createTask();

                      // Close loading dialog
                      Get.back();

                      if (success) {
                        // Show success message
                        Get.snackbar(
                          'Success',
                          'Task added successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: EdgeInsets.all(16),
                          borderRadius: 8,
                        );

                        // Close modal
                        Get.back();

                        // Refresh task list
                        Get.find<TaskController>().refreshTasks();
                      } else {
                        // Show error message
                        Get.snackbar(
                          'Error',
                          'Failed to add task. Please try again.',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: EdgeInsets.all(16),
                          borderRadius: 8,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ).then((_) {
    // Dispose of the controller when the modal is closed
    Get.delete<TaskInputController>();
  });
}

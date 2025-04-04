import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'category_option_widget.dart';
import 'option_button.dart';
import 'date_picker_modal.dart';
import 'date_time_utils.dart';

/// Shows a reminder dialog and returns the selected DateTime
/// Uses a string for the task title instead of TextEditingController to avoid disposal issues
Future<DateTime?> showReminderDialog(
    BuildContext context, String taskTitle) async {
  // Create a local controller for use within this dialog only
  final localTextController = TextEditingController(text: taskTitle);
  DateTime selectedDateTime = DateTime.now().add(Duration(minutes: 5));
  bool isAM = selectedDateTime.hour < 12;

  try {
    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use the local text controller
                  TextField(
                    controller: localTextController,
                    autofocus: false,
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
                  SizedBox(height: 20),

                  // iOS-style picker with selection indicator
                  Container(
                    height: 150,
                    child: Stack(
                      children: [
                        // Selection indicator overlay with gray background
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        // Actual pickers with transparent background
                        Row(
                          children: [
                            // Date picker
                            Expanded(
                              flex: 3,
                              child: CupertinoPicker(
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    DateTime baseDate = DateTime.now();
                                    selectedDateTime = DateTime(
                                      baseDate.year,
                                      baseDate.month,
                                      baseDate.day + index,
                                      selectedDateTime.hour,
                                      selectedDateTime.minute,
                                    );
                                  });
                                },
                                children: List.generate(30, (index) {
                                  DateTime date =
                                      DateTime.now().add(Duration(days: index));
                                  String label = index == 0
                                      ? "Today"
                                      : index == 1
                                          ? "Tomorrow"
                                          : "${getShortDayName(date.weekday)}, ${getMonthName(date.month)} ${date.day}";
                                  return Center(child: Text(label));
                                }),
                              ),
                            ),

                            // Hour picker
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    int hour = index + 1;
                                    if (!isAM) hour += 12;
                                    if (hour == 24) hour = 0;

                                    selectedDateTime = DateTime(
                                      selectedDateTime.year,
                                      selectedDateTime.month,
                                      selectedDateTime.day,
                                      hour,
                                      selectedDateTime.minute,
                                    );
                                  });
                                },
                                children: List.generate(
                                    12,
                                    (index) =>
                                        Center(child: Text("${index + 1}"))),
                              ),
                            ),

                            // Colon separator
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              child: Text(":", style: TextStyle(fontSize: 18)),
                            ),

                            // Minute picker
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedDateTime = DateTime(
                                      selectedDateTime.year,
                                      selectedDateTime.month,
                                      selectedDateTime.day,
                                      selectedDateTime.hour,
                                      index,
                                    );
                                  });
                                },
                                children: List.generate(
                                    60,
                                    (index) => Center(
                                        child: Text(
                                            index.toString().padLeft(2, '0')))),
                              ),
                            ),

                            // AM/PM picker
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    isAM = index == 0;
                                    int hour = selectedDateTime.hour % 12;
                                    if (!isAM) hour += 12;
                                    if (hour == 24) hour = 0;

                                    selectedDateTime = DateTime(
                                      selectedDateTime.year,
                                      selectedDateTime.month,
                                      selectedDateTime.day,
                                      hour,
                                      selectedDateTime.minute,
                                    );
                                  });
                                },
                                children: [
                                  Center(child: Text("AM")),
                                  Center(child: Text("PM")),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Bottom buttons
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            OptionButton(
                              icon: Icons.calendar_today,
                              label: "Today",
                              color: Colors.blue[200]!,
                              onTap: () {
                                // Get the current text
                                final currentText = localTextController.text;

                                // First close the reminder dialog
                                Navigator.pop(context);

                                // Then show the date picker modal
                                showDatePickerModal(
                                  context,
                                  initialDate: DateTime.now(),
                                  initialMode: 'normal',
                                  onDateSelected: (result) {
                                    // Handle date selection if needed
                                    // Reopen with text and date
                                    reopenReminderWithDate(context, currentText,
                                        result.singleDate);
                                  },
                                );
                              },
                            ),
                            SizedBox(width: 10),
                            OptionButton(
                              icon: Icons.description_outlined,
                              label: "Task",
                              color: Colors.blue[200]!,
                              onTap: () {
                                // Get the current text
                                final currentText = localTextController.text;

                                // First close the reminder dialog
                                Navigator.pop(context);

                                // Then you could show the category selection dialog
                                // And reopen with the selected category
                              },
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.blue[300],
                        radius: 24,
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context, selectedDateTime);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  } finally {
    // Ensure the local controller is disposed when the dialog closes
    localTextController.dispose();
  }
}

// Helper function to reopen reminder dialog with a new date
void reopenReminderWithDate(
    BuildContext context, String taskTitle, DateTime? date) {
  if (date != null) {
    // Wait a bit for the previous dialog to close completely
    Future.delayed(Duration(milliseconds: 300), () {
      showReminderDialog(context, taskTitle).then((selectedDateTime) {
        // Handle the result if needed
      });
    });
  }
}

// Helper function to reopen reminder dialog with a new category
void reopenReminderWithCategory(
    BuildContext context, String taskTitle, String category) {
  // Wait a bit for the previous dialog to close completely
  Future.delayed(Duration(milliseconds: 300), () {
    showReminderDialog(context, taskTitle).then((selectedDateTime) {
      // Handle the result if needed
    });
  });
}

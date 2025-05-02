import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Result class for different date modes
class DateSelectionResult {
  final String mode; // 'normal', 'period', 'repeat', 'multiple'
  final DateTime? singleDate; // For normal mode
  final DateTimeRange? dateRange; // For period mode
  final List<DateTime>? multipleDates; // For multiple mode
  final Map<String, dynamic>? repeatConfig; // For repeat mode
  final String displayText;

  DateSelectionResult({
    required this.mode,
    this.singleDate,
    this.dateRange,
    this.multipleDates,
    this.repeatConfig,
    required this.displayText,
  });
}

void showDatePickerModal(
  BuildContext context, {
  required Function(DateSelectionResult) onDateSelected,
  DateTime? initialDate,
  String initialMode = 'normal',
  String taskTitle = '',
}) {
  final DateTime now = DateTime.now();
  final DateTime todayMidnight = DateTime(now.year, now.month, now.day);

  // State variables for the StatefulBuilder
  String selectedMode = initialMode;
  DateTime selectedDate = initialDate ?? todayMidnight;
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  List<DateTime> selectedDates = [];
  Map<String, dynamic> repeatSettings = {
    'frequency': 'weekly',
    'interval': 1,
    'endDate': null,
  };

  String buttonText =
      initialDate != null && !_isSameDay(initialDate, todayMidnight)
          ? DateFormat('MMM d').format(initialDate)
          : 'Today';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface, // Theme color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          void selectModeAndUpdateUI(String mode) {
            setState(() {
              selectedMode = mode;
              // Reset any relevant state when changing modes
              if (mode == 'normal') {
                buttonText = _isSameDay(selectedDate, todayMidnight)
                    ? 'Today'
                    : DateFormat('MMM d').format(selectedDate);
              } else if (mode == 'period') {
                rangeStartDate = selectedDate;
                rangeEndDate = null;
                buttonText = 'Select range';
              } else if (mode == 'multiple') {
                selectedDates = [selectedDate];
                buttonText = '1 day';
              } else if (mode == 'repeat') {
                buttonText = 'Weekly';
              }
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Make the text clickable to open task input modal
                GestureDetector(
                  onTap: () {
                    // Close the date picker modal to return to task input
                    Navigator.pop(context);
                  },
                  child: Text(
                    taskTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Options bar
                Row(
                  children: [
                    // Calendar button with current selection
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18),
                          SizedBox(width: 4),
                          Text(
                            buttonText,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.close,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            size: 20),
                      ),
                    ),

                    // Scrollable options section
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            _buildOptionPill(
                              'normal',
                              isSelected: selectedMode == 'normal',
                              onTap: () => selectModeAndUpdateUI('normal'),
                              context: context,
                            ),
                            SizedBox(width: 8),
                            _buildOptionPill(
                              'period',
                              isSelected: selectedMode == 'period',
                              onTap: () => selectModeAndUpdateUI('period'),
                              context: context,
                            ),
                            SizedBox(width: 8),
                            _buildOptionPill(
                              'repeat',
                              isSelected: selectedMode == 'repeat',
                              onTap: () => selectModeAndUpdateUI('repeat'),
                              context: context,
                            ),
                            SizedBox(width: 8),
                            _buildOptionPill(
                              'multiple',
                              isSelected: selectedMode == 'multiple',
                              onTap: () => selectModeAndUpdateUI('multiple'),
                              context: context,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Send button
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        DateSelectionResult result;

                        // Build result based on the selected mode
                        switch (selectedMode) {
                          case 'period':
                            if (rangeStartDate != null &&
                                rangeEndDate != null) {
                              final range = DateTimeRange(
                                  start: rangeStartDate!, end: rangeEndDate!);
                              final start =
                                  DateFormat('MMM d').format(range.start);
                              final end = DateFormat('MMM d').format(range.end);
                              result = DateSelectionResult(
                                mode: 'period',
                                dateRange: range,
                                displayText: '$start - $end',
                              );
                            } else {
                              // Incomplete range selection
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Please select both start and end dates"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            break;

                          case 'multiple':
                            if (selectedDates.isNotEmpty) {
                              result = DateSelectionResult(
                                mode: 'multiple',
                                multipleDates: selectedDates,
                                displayText:
                                    '${selectedDates.length} day${selectedDates.length > 1 ? 's' : ''}',
                              );
                            } else {
                              // No dates selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Please select at least one date"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            break;

                          case 'repeat':
                            result = DateSelectionResult(
                              mode: 'repeat',
                              singleDate: selectedDate,
                              repeatConfig: repeatSettings,
                              displayText:
                                  'Repeating ${repeatSettings['frequency']}',
                            );
                            break;

                          case 'normal':
                          default:
                            result = DateSelectionResult(
                              mode: 'normal',
                              singleDate: selectedDate,
                              displayText: buttonText,
                            );
                            break;
                        }

                        onDateSelected(result);
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 24,
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Show mode-specific UI
                if (selectedMode == 'repeat')
                  _buildRepeatOptions(
                    context,
                    repeatSettings,
                    (newSettings) {
                      setState(() {
                        repeatSettings = newSettings;

                        // Update button text based on frequency
                        String frequency = repeatSettings['frequency'];
                        buttonText =
                            'Repeat ${frequency.substring(0, 1).toUpperCase()}${frequency.substring(1)}';
                      });
                    },
                  )
                else
                  Expanded(
                    child: _buildCalendar(
                      context,
                      selectedDate,
                      todayMidnight,
                      selectedMode,
                      selectedDates,
                      rangeStartDate,
                      rangeEndDate,
                      (newDate) {
                        // Validate date is not before today
                        if (newDate.isBefore(todayMidnight)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("You can't select dates before today"),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        // Handle selection based on mode
                        switch (selectedMode) {
                          case 'normal':
                            setState(() {
                              selectedDate = newDate;
                              buttonText = _isSameDay(newDate, todayMidnight)
                                  ? 'Today'
                                  : DateFormat('MMM d').format(newDate);
                            });
                            // Close the modal for normal mode
                            onDateSelected(DateSelectionResult(
                              mode: 'normal',
                              singleDate: selectedDate,
                              displayText: buttonText,
                            ));
                            Navigator.pop(context);
                            break;

                          case 'period':
                            if (rangeStartDate == null ||
                                (rangeStartDate != null &&
                                    rangeEndDate != null)) {
                              // Start a new range
                              setState(() {
                                rangeStartDate = newDate;
                                rangeEndDate = null;
                                buttonText =
                                    'From ${DateFormat('MMM d').format(newDate)}';
                              });
                            } else {
                              // Complete the range
                              DateTime start, end;
                              if (newDate.isBefore(rangeStartDate!)) {
                                // Swap if end date is before start date
                                end = rangeStartDate!;
                                start = newDate;
                              } else {
                                start = rangeStartDate!;
                                end = newDate;
                              }

                              final startText =
                                  DateFormat('MMM d').format(start);
                              final endText = DateFormat('MMM d').format(end);
                              final displayText = '$startText - $endText';

                              // Close the picker and return the result
                              final result = DateSelectionResult(
                                mode: 'period',
                                dateRange:
                                    DateTimeRange(start: start, end: end),
                                displayText: displayText,
                              );
                              onDateSelected(result);
                              Navigator.pop(context);
                              return; // Exit the function early
                            }
                            break;

                          case 'multiple':
                            setState(() {
                              if (selectedDates
                                  .any((date) => _isSameDay(date, newDate))) {
                                // Remove date if already selected
                                selectedDates.removeWhere(
                                    (date) => _isSameDay(date, newDate));
                              } else {
                                // Add date
                                selectedDates.add(newDate);
                              }

                              buttonText =
                                  '${selectedDates.length} day${selectedDates.length > 1 ? 's' : ''}';
                            });
                            break;

                          case 'repeat':
                            setState(() {
                              selectedDate = newDate;
                              buttonText =
                                  'Repeat from ${DateFormat('MMM d').format(newDate)}';
                            });
                            // No auto-close for repeat mode as we need to set up repeat options
                            break;
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildOptionPill(
  String text, {
  required bool isSelected,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Widget _buildRepeatOptions(
  BuildContext context,
  Map<String, dynamic> settings,
  Function(Map<String, dynamic>) onSettingsChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat frequency:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFrequencyOption(
              'Daily',
              isSelected: settings['frequency'] == 'daily',
              onTap: () {
                final newSettings = Map<String, dynamic>.from(settings);
                newSettings['frequency'] = 'daily';
                onSettingsChanged(newSettings);
              },
            ),
            _buildFrequencyOption(
              'Weekly',
              isSelected: settings['frequency'] == 'weekly',
              onTap: () {
                final newSettings = Map<String, dynamic>.from(settings);
                newSettings['frequency'] = 'weekly';
                onSettingsChanged(newSettings);
              },
            ),
            _buildFrequencyOption(
              'Monthly',
              isSelected: settings['frequency'] == 'monthly',
              onTap: () {
                final newSettings = Map<String, dynamic>.from(settings);
                newSettings['frequency'] = 'monthly';
                onSettingsChanged(newSettings);
              },
            ),
            _buildFrequencyOption(
              'Yearly',
              isSelected: settings['frequency'] == 'yearly',
              onTap: () {
                final newSettings = Map<String, dynamic>.from(settings);
                newSettings['frequency'] = 'yearly';
                onSettingsChanged(newSettings);
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Repeat every:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        // Interval slider or number picker
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('1'),
              Expanded(
                child: Slider(
                  value: settings['interval'].toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    final newSettings = Map<String, dynamic>.from(settings);
                    newSettings['interval'] = value.toInt();
                    onSettingsChanged(newSettings);
                  },
                ),
              ),
              Text('10'),
            ],
          ),
        ),
        Center(
          child: Text(
            '${settings['interval']} ${settings['frequency']}${settings['interval'] > 1 ? 's' : ''}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFrequencyOption(
  String text, {
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected ? Border.all(color: Colors.blue[400]!, width: 2) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

Widget _buildCalendar(
  BuildContext context,
  DateTime selectedDate,
  DateTime todayDate,
  String mode,
  List<DateTime> multipleDates,
  DateTime? rangeStartDate,
  DateTime? rangeEndDate,
  Function(DateTime) onDateSelected,
) {
  final now = DateTime.now();

  // Generate month name and year
  final monthYear = DateFormat('MMMM yyyy').format(selectedDate);

  // Create weekday headers
  final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Get the year and month of the selected date for the calendar
  final calendarYear = selectedDate.year;
  final calendarMonth = selectedDate.month;

  // Calculate days in month
  final daysInMonth = DateTime(calendarYear, calendarMonth + 1, 0).day;

  // Calculate first day of month offset
  final firstDayOfMonth = DateTime(calendarYear, calendarMonth, 1);
  final firstDayOffset = firstDayOfMonth.weekday % 7;

  // Create calendar grid items
  List<Widget> calendarItems = [];

  // Add month name and year controls
  calendarItems.add(Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          monthYear,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ));

  // Add weekday headers
  List<Widget> weekdayHeaders = [];
  for (final day in weekDays) {
    weekdayHeaders.add(
      Expanded(
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
  calendarItems.add(Row(children: weekdayHeaders));

  // Add blank spaces for offset
  List<Widget> rowItems = [];
  for (int i = 0; i < firstDayOffset; i++) {
    rowItems.add(Expanded(child: SizedBox()));
  }

  // Add days of month
  for (int day = 1; day <= daysInMonth; day++) {
    final currentDate = DateTime(calendarYear, calendarMonth, day);
    final isToday = _isSameDay(currentDate, todayDate);
    final isPastDate = currentDate.isBefore(todayDate);

    // Check if this date is selected based on the mode
    bool isSelected = false;
    bool isInRange = false;
    Color? backgroundColor;

    switch (mode) {
      case 'normal':
        isSelected = _isSameDay(currentDate, selectedDate);
        backgroundColor = isSelected
            ? Colors.blue[300]
            : (isToday ? Colors.blue[50] : Colors.transparent);
        break;

      case 'period':
        isSelected =
            rangeStartDate != null && _isSameDay(currentDate, rangeStartDate) ||
                rangeEndDate != null && _isSameDay(currentDate, rangeEndDate);

        if (rangeStartDate != null && rangeEndDate != null) {
          // Determine if this date is in the selected range
          isInRange = (currentDate.isAfter(rangeStartDate!) &&
              currentDate.isBefore(rangeEndDate!));

          if (isSelected) {
            backgroundColor = Colors.blue[300]; // Range endpoints
          } else if (isInRange) {
            backgroundColor = Colors.blue[100]; // Dates in between range
          } else {
            backgroundColor = isToday ? Colors.blue[50] : Colors.transparent;
          }
        } else if (rangeStartDate != null &&
            _isSameDay(currentDate, rangeStartDate!)) {
          backgroundColor = Colors.blue[300]; // Just the start date
        } else {
          backgroundColor = isToday ? Colors.blue[50] : Colors.transparent;
        }
        break;

      case 'multiple':
        isSelected = multipleDates.any((date) => _isSameDay(date, currentDate));
        backgroundColor = isSelected
            ? Colors.blue[300]
            : (isToday ? Colors.blue[50] : Colors.transparent);
        break;

      case 'repeat':
        isSelected = _isSameDay(currentDate, selectedDate);
        backgroundColor = isSelected
            ? Colors.blue[300]
            : (isToday ? Colors.blue[50] : Colors.transparent);
        break;
    }

    rowItems.add(
      Expanded(
        child: GestureDetector(
          onTap: isPastDate ? null : () => onDateSelected(currentDate),
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blue[400]!, width: 1)
                  : null,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isPastDate
                        ? Colors.grey[400] // Greyed out past dates
                        : (isSelected ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Start a new row after Saturday (or when we've filled a row)
    if ((firstDayOffset + day) % 7 == 0 || day == daysInMonth) {
      if (day == daysInMonth && (firstDayOffset + day) % 7 != 0) {
        // Fill in remaining spaces in last row
        final remainingSpaces = 7 - (firstDayOffset + day) % 7;
        for (int i = 0; i < remainingSpaces; i++) {
          rowItems.add(Expanded(child: SizedBox()));
        }
      }

      calendarItems.add(Container(
        height: 40,
        child: Row(children: [...rowItems]),
      ));
      rowItems = [];
    }
  }

  return Column(
    children: calendarItems,
  );
}

// Helper function to check if two dates are the same day
bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

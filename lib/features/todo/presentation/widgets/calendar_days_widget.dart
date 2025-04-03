import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDaysWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarDaysWidget({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstDay =
        focusedDay.subtract(Duration(days: focusedDay.weekday % 7));
    final today = DateTime.now();

    return Container(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = firstDay.add(Duration(days: index));
          final isSelected = isSameDay(day, selectedDay);
          final isToday = isSameDay(day, today);
          final isWeekend = day.weekday == DateTime.saturday ||
              day.weekday == DateTime.sunday;

          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              decoration: BoxDecoration(
                color: isToday ? Colors.blue.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? Border.all(color: Colors.grey[400]!, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(day),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: isWeekend ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('EEE').format(day),
                    style: TextStyle(
                        fontSize: 13,
                        color: isWeekend ? Colors.red : Colors.black),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: Colors.redAccent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

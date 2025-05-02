import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final DateTime focusedDay;

  const CalendarHeaderWidget({Key? key, required this.focusedDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('MMMM').format(focusedDay);
    final nextMonthDate = DateTime(focusedDay.year, focusedDay.month + 1);
    final nextMonth = DateFormat('MMMM').format(nextMonthDate);

    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, top: 10.0, bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            currentMonth,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            nextMonth,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
                color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

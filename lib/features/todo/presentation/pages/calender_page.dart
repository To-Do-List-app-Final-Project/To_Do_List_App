import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Sample task data
  Map<DateTime, List<String>> _tasks = {
    DateTime(2025, 3, 30): ['thank'],
    DateTime(2025, 3, 31): ['thank'],
    DateTime(2025, 4, 2): ['Go to'],
    DateTime(2025, 4, 7): ['thank'],
    DateTime(2025, 4, 14): ['thank'],
    DateTime(2025, 4, 17): ['thank'],
    DateTime(2025, 4, 20): ['thank'],
    DateTime(2025, 4, 22): ['thank'],
  };

  List<String> _getTasksForDay(DateTime day) {
    // Using the isSameDay function to ensure proper date comparison
    for (final taskDay in _tasks.keys) {
      if (isSameDay(taskDay, day)) {
        return _tasks[taskDay] ?? [];
      }
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM').format(_focusedDay),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerVisible: false,
              daysOfWeekVisible: true,
              sixWeekMonthsEnforced: true,

              // Calendar styling
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                weekendTextStyle: TextStyle(color: Colors.red),
                holidayTextStyle: TextStyle(color: Colors.red),
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.lightBlue.shade100,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // Event markers
              eventLoader: _getTasksForDay,

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        height: 16,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            events[0] as String,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
                outsideBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),

              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _showTasksBottomSheet(selectedDay);
                });
              },

              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _showTasksBottomSheet(DateTime day) {
    String formattedDate = DateFormat('EEE, MMM d').format(day);
    int daysUntil = day.difference(DateTime.now()).inDays;
    String daysText = 'D';
    if (daysUntil > 0) {
      daysText += ' +$daysUntil';
    } else if (daysUntil < 0) {
      daysText += ' ${daysUntil}';
    } else {
      daysText += ' 0';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          daysText,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.sentiment_satisfied_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for tasks
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black54,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text("Add a Task"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/calendar_days_widget.dart';
import '../widgets/add_task_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalendarHeaderWidget(focusedDay: _focusedDay),
            CalendarDaysWidget(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Task items and containers (unchanged)
                  ListTile(
                    title: Text('Unchecked Task'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildTodayTasksContainer(context),
                  const SizedBox(height: 10),
                  _buildSomedayTasksContainer(context),
                  const SizedBox(height: 20),
                  Center(child: Text('End of list')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasksContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskContainerHeader(),
          const SizedBox(height: 10),
          _buildAddTaskButton(context),
        ],
      ),
    );
  }

  Widget _buildTaskContainerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text('Sun, 3/23', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.edit, color: Colors.grey)),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.sentiment_satisfied, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSomedayTasksContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Someday',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 10),
          ListTile(
            title: Text(
                'Go to the post-office to pickup Goods which was sent months ago'),
            trailing: Icon(Icons.bookmark_border),
          ),
          const SizedBox(height: 10),
          _buildAddTaskButton(context),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showAddTaskModal(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('+ Add a Task', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/data/models/category_model.dart';
import 'package:to_do_list_app/features/todo/data/models/tasks_model.dart';
import 'package:to_do_list_app/features/todo/presentation/controllers/category_controller.dart';
import 'package:to_do_list_app/features/todo/presentation/controllers/task_controller.dart';
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
  final CategoryController _categoryController = Get.find<CategoryController>();
  final TaskController _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _categoryController.fetchCategories();
    // Tasks are already fetched in TaskController's onInit()
  }

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
                  // Task items and containers
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
          Obx(() {
            final todayTasks = _getTodayTasks();
            if (todayTasks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No tasks for today',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: todayTasks.length,
              itemBuilder: (context, index) =>
                  _buildTaskItem(todayTasks[index]),
            );
          }),
          _buildAddTaskButton(context),
        ],
      ),
    );
  }

  List<Task> _getTodayTasks() {
    final DateTime today = DateTime.now();
    return _taskController.tasks.where((task) {
      final taskDate = DateTime.parse(task.scheduleDate);
      return _isSameDay(taskDate, today);
    }).toList();
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

  Widget _buildTaskCard(dynamic task) {
    final String title = task['title'] ?? 'Untitled Task';
    final String description = task['description'] ?? 'No description';
    final dynamic category = task['categoryId'];
    final String categoryColor =
        category != null ? category['color'] ?? '#FFB6B9' : '#FFB6B9';
    final String categoryTitle = category != null
        ? category['title'] ?? 'Uncategorized'
        : 'Uncategorized';

    // Convert hex color to Flutter color
    Color color;
    try {
      color = Color(int.parse(categoryColor.replaceAll('#', '0xFF')));
    } catch (e) {
      // Fallback color if parsing fails
      color = Colors.blue;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categoryTitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Priority indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task['priority'] ?? 'Medium')
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task['priority'] ?? 'Medium',
                    style: TextStyle(
                      color: _getPriorityColor(task['priority'] ?? 'Medium'),
                      fontSize: 12,
                    ),
                  ),
                ),
                // Status indicator
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      task['status'] ?? 'Pending',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Upcoming Tasks',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 10),
          Obx(() {
            // Filter tasks for future dates (not today)
            final futureTasks = _getFutureTasks();
            if (futureTasks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No upcoming tasks',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: futureTasks.length,
                itemBuilder: (context, index) =>
                    _buildTaskItem(futureTasks[index]),
              ),
            );
          }),
          const SizedBox(height: 10),
          _buildAddTaskButton(context),
        ],
      ),
    );
  }

  List<Task> _getFutureTasks() {
    final DateTime today = DateTime.now();
    return _taskController.tasks.where((task) {
      final taskDate = DateTime.parse(task.scheduleDate);
      return !_isSameDay(taskDate, today);
    }).toList();
  }

  // Update the task item builder to work with Task objects
  Widget _buildTaskItem(Task task) {
    // Access properties directly from the Task object
    final String title = task.title ?? 'Untitled Task';
    final String description = task.description ?? '';
    final dynamic category = task.categoryId;

    // Handle category color
    String categoryColor = '#FFB6B9';

    // Convert hex color to Flutter color
    Color color;
    try {
      color = Color(int.parse(categoryColor.replaceAll('#', '0xFF')));
    } catch (e) {
      // Fallback color if parsing fails
      color = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(description),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox for task completion
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                // Toggle task completion status
                _taskController.toggleTaskStatus(task.id);
              },
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority ?? 'Medium')
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.priority ?? 'Medium',
                style: TextStyle(
                  color: _getPriorityColor(task.priority ?? 'Medium'),
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.more_vert),
          ],
        ),
        onTap: () {
          // Handle task tap
        },
      ),
    );
  }

  // Helper method to determine priority color
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

import 'package:get/get.dart';
import 'package:to_do_list_app/features/todo/data/models/tasks_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();

  // Observable state variables
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  final RxString selectedCategoryId = ''.obs;

  // Pagination settings
  final int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      tasks.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !refresh) return;

    try {
      isLoading.value = true;
      error.value = '';

      final newTasks = await _repository.getTasks(
        pageSize: pageSize,
        pageNo: currentPage.value,
        categoryId: selectedCategoryId.value.isNotEmpty
            ? selectedCategoryId.value
            : null,
      );
      final existingTaskIds = tasks.map((task) => task.id).toSet();

      for (final task in newTasks) {
        if (!existingTaskIds.contains(task.id)) {
          tasks.add(task);
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTasks() async {
    await fetchTasks(refresh: true);
  }

  Future<void> filterByCategory(String categoryId) async {
    selectedCategoryId.value = categoryId;
    await refreshTasks();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required String priority,
    required String categoryId,
    required String scheduleDate,
    DateTime? reminderDate,
    required String status,
    required String repeat,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final newTask = Task(
        title: title,
        description: description,
        priority: priority,
        categoryId: categoryId,
        scheduleDate: scheduleDate,
        reminderDate: reminderDate,
        status: status,
        repeat: repeat,
        isCompleted: false,
      );

      final createdTask = await _repository.createTask(newTask);
      tasks.insert(0, createdTask); // Add to beginning of list
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedTask = await _repository.updateTask(task);

      final index = tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
        tasks.refresh(); // Important to notify observers of the list change
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _repository.deleteTask(taskId);

      if (success) {
        tasks.removeWhere((task) => task.id == taskId);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTaskStatus(String taskId) async {
    try {
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index == -1) return;

      final task = tasks[index];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

      // Optimistic update
      tasks[index] = updatedTask;
      tasks.refresh();

      // await _repository.toggleTaskStatus(taskId);
    } catch (e) {
      // Revert optimistic update in case of error
      refreshTasks();
      error.value = e.toString();
    }
  }
}

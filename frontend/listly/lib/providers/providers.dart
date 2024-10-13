import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/todo.dart';

// Provide a singleton instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StateProvider for the current logged-in user
final userProvider = StateProvider<User?>((ref) => null);

// Create a StateNotifier to manage the list of tasks
class TaskNotifier extends StateNotifier<List<ToDo>> {
  TaskNotifier() : super([]); // Start with an empty list of tasks

  // Method to add a new task
  void addTask(ToDo task) {
    state = [...state, task]; // Add a new task and update the state
  }

  // Method to update an existing task
  void updateTask(ToDo task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t // Update the specific task
    ];
  }

  // Method to set initial tasks from API
  void setTasks(List<ToDo> tasks) {
    state = tasks; // Set initial tasks (e.g., from API)
  }

  // Method to remove a task by ID
  void removeTask(String taskId) {
    state = state
        .where((task) => task.id != taskId)
        .toList(); // Filter out the task to delete
  }
}

// Provider for TaskNotifier
final tasksProvider = StateNotifierProvider<TaskNotifier, List<ToDo>>((ref) {
  return TaskNotifier();
});

// Provider for the visibility state of the AddToDoWidget
final addToDoWidgetVisibilityProvider = StateProvider<bool>((ref) => false);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../providers/auth_providers.dart';
import 'dart:convert'; // Add this import at the top of your file

class TaskNotifier extends StateNotifier<List<ToDo>> {
  TaskNotifier() : super([]);

  // Method to add a new task
  void addTask(ToDo task) {
    state = [...state, task];
  }

  // Method to update an existing task
  void updateTask(ToDo task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t
    ];
  }

  // Method to set initial tasks from API
  Future<void> fetchTasks(String token) async {
    try {
      final List<dynamic> response = await ApiService.fetchTasks(token);
      state = response.map((taskJson) => ToDo.fromJson(taskJson)).toList();
    } catch (error) {
      throw Exception('Error fetching tasks: $error');
    }
  }

  // Method to remove a task by ID
  void removeTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

// Method to add a task through API
  Future<void> addTaskViaAPI(String taskDescription, String token) async {
    final response = await ApiService.addTask(taskDescription, token);

    // Parse the response from JSON string to Map
    final Map<String, dynamic> jsonResponse = jsonDecode(response);

    final ToDo newTask = ToDo.fromJson(jsonResponse);
    addTask(newTask);
  }

  // Method to update a task through API
  Future<void> updateTaskViaAPI(ToDo task, String token) async {
    await ApiService.updateTask(task, token);
    updateTask(task);
  }

  // Method to delete a task through API
  Future<void> deleteTaskViaAPI(String taskId, String token) async {
    await ApiService.deleteTask(taskId, token);
    removeTask(taskId);
  }
}

// Provider for TaskNotifier
final tasksProvider = StateNotifierProvider<TaskNotifier, List<ToDo>>((ref) {
  return TaskNotifier();
});

// Provider for the visibility state of the AddToDoWidget
final addToDoWidgetVisibilityProvider = StateProvider<bool>((ref) => false);

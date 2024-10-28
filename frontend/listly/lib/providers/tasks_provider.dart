//tasks_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../services/socket_service_tasks.dart';
import 'dart:convert';
import './auth_providers.dart';
import './socket_service_tasks_provider.dart';

class TaskNotifier extends StateNotifier<List<ToDo>> {
  final SocketServiceTasks socketService;

  TaskNotifier(this.socketService, String token) : super([]) {
    // Connect to the socket service
    socketService.connect(token, (Map<String, dynamic> updatedTaskJson) {
      print('Socket event received: $updatedTaskJson');

      final updatedTaskId = updatedTaskJson['id'] ?? updatedTaskJson['_id'];

      // Check if the task is deleted
      if (updatedTaskJson['deleted'] == true) {
        print('Task marked as deleted: $updatedTaskId');
        removeTask(updatedTaskId);
      } else if (state.every((task) => task.id != updatedTaskId)) {
        // Handle new task addition by creating a ToDo object
        final newTask = ToDo.fromJson(updatedTaskJson);
        addTask(newTask, fromSocket: true); // Mark as added from socket
      } else {
        print('Task update received: $updatedTaskId');
        final updatedTask = ToDo.fromJson(updatedTaskJson);
        updateTask(updatedTask); // Call updateTask directly
      }
    });
  }

  Future<void> removeTask(String? taskId) async {
    if (taskId == null || taskId.isEmpty) {
      print('Invalid task ID for removal');
      return;
    }

    print('Removing task with ID: $taskId');
    state = state.where((task) => task.id != taskId).toList();

    // Emit task deletion to the server
    print('Emitting task deletion for ID: $taskId');
    socketService.emitTaskUpdate({
      '_id': taskId,
      'deleted': true, // Mark the task as deleted
    });
  }

  Future<void> addTask(ToDo task, {bool fromSocket = false}) async {
    print('Adding task: ${task.id}, fromSocket: $fromSocket');

    // Prevent duplication by checking if it's already in the state
    if (state.any((t) => t.id == task.id)) {
      print('Task already exists: ${task.id}');
      return;
    }

    // Add task to the state
    state = [...state, task];

    // Emit task update only if it wasn't added via the socket
    if (!fromSocket) {
      print('Emitting task update: ${task.toJson()}');
      // Add an identifier to indicate this is an addition
      socketService.emitTaskUpdate({
        ...task.toJson(),
        'added': true, // Mark the task as added
      });
    }
  }

  // Method to update an existing task
  Future<void> updateTask(ToDo task) async {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t
    ];
    print('Emitting task update: ${task.toJson()}');
    socketService.emitTaskUpdate(task.toJson()); // Emit updated task to socket
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

  Future<void> addTaskViaAPI(String taskDescription, String token) async {
    final response = await ApiService.addTask(taskDescription, token);
    final Map<String, dynamic> jsonResponse = jsonDecode(response);
    final ToDo newTask = ToDo.fromJson(jsonResponse);

    // Emit the new task to the socket
    socketService
        .emitTaskUpdate(newTask.toJson()); // Emit the added task to socket

    addTask(newTask); // Handle adding to the state
  }

  Future<void> updateTaskViaAPI(ToDo task, String token) async {
    await ApiService.updateTask(task, token);
    updateTask(task); // Handle updating state
  }

  Future<void> deleteTaskViaAPI(String taskId, String token) async {
    await ApiService.deleteTask(taskId, token);
    removeTask(taskId); // Handle removing from the state
  }
}

// Provider for TaskNotifier
final tasksProvider = StateNotifierProvider<TaskNotifier, List<ToDo>>((ref) {
  final socketService =
      ref.watch(socketServiceTasksProvider); // Watch socket service
  final token =
      ref.watch(authServiceProvider).currentUser?.token ?? ''; // Get the token
  return TaskNotifier(socketService, token);
});

//socket_service_tasks_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service_tasks.dart';
import '../models/todo.dart';
import '../providers/tasks_provider.dart';
import '../providers/auth_providers.dart';

final socketServiceTasksProvider = Provider<SocketServiceTasks>((ref) {
  final socketServiceTasks = SocketServiceTasks();
  return socketServiceTasks;
});

// Callback to handle task updates via socket events
final taskUpdateProvider = Provider<void Function(ToDo)>((ref) {
  return (updatedTask) {
    final token = ref.watch(authServiceProvider).currentUser?.token;
    if (token != null) {
      ref
          .read(tasksProvider.notifier)
          .fetchTasks(token); // Fetch tasks when the task is updated
    }
  };
});

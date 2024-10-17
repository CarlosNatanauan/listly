import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service_tasks.dart'; // Import your tasks socket service
import '../models/todo.dart'; // Import your ToDo model
import '../providers/tasks_provider.dart'; // Import tasks provider
import '../providers/auth_providers.dart'; // Import for token

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

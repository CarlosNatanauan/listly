import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../models/todo.dart'; // Import the ToDo model
import '../services/api_service.dart'; // Import the API service
import '../services/auth_service.dart'; // Import the API service
import '../providers/providers.dart';

class TodoScreen extends ConsumerStatefulWidget {
  final List<ToDo> tasks;

  TodoScreen({required this.tasks});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  late List<ToDo> notCompletedTasks;
  late List<ToDo> completedTasks;

  @override
  void initState() {
    super.initState();
    _updateTaskLists(); // Initialize the task lists
  }

  void _updateTaskLists() {
    notCompletedTasks = widget.tasks.where((task) => !task.completed).toList();
    completedTasks = widget.tasks.where((task) => task.completed).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Display Not Completed tasks if they exist
        if (notCompletedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Not Completed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...notCompletedTasks.map((task) => _buildTaskTile(context, task)),
        ],

        // Display Completed tasks if they exist
        if (completedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Completed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...completedTasks.map((task) => _buildTaskTile(context, task)),
        ],
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, ToDo task) {
    return ListTile(
      title: Text(task.task),
      trailing: Checkbox(
        value: task.completed,
        onChanged: (bool? newValue) async {
          if (newValue != null) {
            final updatedTask = ToDo(
              id: task.id,
              task: task.task,
              completed: newValue,
            );

            // Access the AuthService using Riverpod
            final authService = ref.read(authServiceProvider);
            final token = await authService.getToken();

            // Check if the token is null and handle it
            if (token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Failed to retrieve authentication token')),
              );
              return; // Exit if token is null
            }

            try {
              // Update task in the database with the token
              await ApiService.updateTask(updatedTask, token); // Safe now

              // Update the original tasks list
              setState(() {
                // Find the index of the original task
                final index = widget.tasks.indexWhere((t) => t.id == task.id);
                if (index != -1) {
                  // Update the original task in the list
                  widget.tasks[index] = updatedTask;
                }
                // Update local state lists
                _updateTaskLists();
              });

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task updated successfully')),
              );
            } catch (error) {
              // Handle error
              print('Error updating task: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating task')),
              );
            }
          }
        },
      ),
    );
  }
}

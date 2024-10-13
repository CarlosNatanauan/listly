import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../models/todo.dart'; // Import the ToDo model
import '../services/api_service.dart'; // Import the API service
import '../services/auth_service.dart'; // Import the Auth service
import '../providers/providers.dart';

class TodoScreen extends ConsumerStatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  // State variable to track the visibility of completed tasks
  bool _showCompletedTasks = false;

  @override
  Widget build(BuildContext context) {
    // Watch the tasks from the provider
    final tasks = ref.watch(tasksProvider);

    // Separate the tasks into completed and not completed
    final notCompletedTasks = tasks.where((task) => !task.completed).toList();
    final completedTasks = tasks.where((task) => task.completed).toList();

    return ListView(
      children: [
        // Display Not Completed tasks if they exist
        if (notCompletedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Not Completed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
          ),
          ...notCompletedTasks.map((task) => _buildTaskCard(context, task)),
        ],

        // Display Completed tasks section with dropdown
        if (completedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _showCompletedTasks = !_showCompletedTasks;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                  Icon(
                    _showCompletedTasks
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),
          if (_showCompletedTasks) ...[
            ...completedTasks.map((task) => _buildTaskCard(context, task)),
          ],
        ],
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, ToDo task) {
    return Dismissible(
      key: Key(task.id), // Unique key for each task
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red, // Background color when swiped
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart, // Swipe from right to left
      onDismissed: (direction) async {
        // Access the AuthService using Riverpod
        final authService = ref.read(authServiceProvider);
        final token = await authService.getToken();

        // Check if the token is null and handle it
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to retrieve authentication token')),
          );
          return; // Exit if token is null
        }

        try {
          // Call deleteTask to delete from the server
          await ApiService.deleteTask(task.id, token);

          // Remove the task from the provider
          ref.read(tasksProvider.notifier).removeTask(task.id);

          // Show success message
          /*
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${task.task} deleted')),
        );
        */
        } catch (error) {
          // Handle error
          print('Error deleting task: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting task')),
          );
        }
      },
      child: Card(
        elevation: 2, // Elevation for the floating effect
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Checkbox(
                value: task.completed,
                activeColor: Color(0xFFFF725E), // Set the color when checked
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
                            content: Text(
                                'Failed to retrieve authentication token')),
                      );
                      return; // Exit if token is null
                    }

                    try {
                      // Update task in the database with the token
                      await ApiService.updateTask(
                          updatedTask, token); // Safe now

                      // Update the original tasks list in the provider
                      ref.read(tasksProvider.notifier).updateTask(updatedTask);

                      // Show success message
                      /*
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Task updated successfully')),
                    );
                    */
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
              // Text styling for completed tasks
              Expanded(
                child: Text(
                  task.task,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/auth_service.dart';
import '../providers/auth_providers.dart';
import '../widgets/edit_todo_widget.dart';
import '../providers/fab_visibility_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/socket_service_tasks_provider.dart'; // Import the Socket Provider

class TodoScreen extends ConsumerStatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  bool _showCompletedTasks = false;
  bool _isEditToDoVisible = false;
  TextEditingController _editToDoTextController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ToDo? _selectedTask;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    // Filter tasks based on the search query, regardless of completion status
    final filteredTasks = tasks
        .where((task) =>
            task.task.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Separate the filtered tasks into not completed and completed
    final notCompletedTasks =
        filteredTasks.where((task) => !task.completed).toList();
    final completedTasks =
        filteredTasks.where((task) => task.completed).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'To-do',
              style: TextStyle(
                color: Color(0xFFFF725E),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildSearchBar(),
        Expanded(
          child: Stack(
            children: [
              ListView(
                children: [
                  if (notCompletedTasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 4.0),
                      child:
                          Text('Not Completed', style: TextStyle(fontSize: 16)),
                    ),
                    ...notCompletedTasks
                        .map((task) => _buildTaskCard(context, task)),
                  ],
                  if (completedTasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 4.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showCompletedTasks =
                                !_showCompletedTasks; // Toggle state
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Completed', style: TextStyle(fontSize: 16)),
                            Icon(_showCompletedTasks
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    if (_showCompletedTasks) ...[
                      ...completedTasks
                          .map((task) => _buildTaskCard(context, task)),
                    ],
                  ],
                ],
              ),
              if (_isEditToDoVisible)
                EditToDoWidget(
                  onClose: _toggleEditToDoWidget,
                  textController: _editToDoTextController,
                  onSave: _saveEditedToDo,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, ToDo task) {
    return GestureDetector(
      onTap: () => _showEditToDoWidget(task),
      child: Dismissible(
        key: Key(task.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) async {
          await _deleteTask(task);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${task.task} deleted')),
          );
        },
        child: Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Checkbox(
                  value: task.completed,
                  activeColor: Color(0xFFFF725E),
                  onChanged: (bool? newValue) async {
                    if (newValue != null) {
                      final updatedTask = ToDo(
                        id: task.id,
                        task: task.task,
                        completed: newValue,
                      );
                      await _updateTask(updatedTask);
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    task.task,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontSize: 14.0),
            decoration: InputDecoration(
              labelText: 'Search Tasks',
              labelStyle: TextStyle(fontSize: 14.0),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, size: 20.0, color: Colors.grey),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }

  void _toggleEditToDoWidget() {
    setState(() {
      _isEditToDoVisible = !_isEditToDoVisible;
      if (_isEditToDoVisible) {
        ref.read(fabVisibilityProvider.notifier).hide(); // Hide FAB
      } else {
        ref.read(fabVisibilityProvider.notifier).show(); // Show FAB
        _editToDoTextController.clear();
        _selectedTask = null;
      }
    });
  }

  void _showEditToDoWidget(ToDo task) {
    _selectedTask = task;
    _editToDoTextController.text = task.task;
    _toggleEditToDoWidget();
  }

  void _saveEditedToDo() async {
    final editedTaskText = _editToDoTextController.text.trim();
    if (_selectedTask != null && editedTaskText.isNotEmpty) {
      final updatedTask = ToDo(
        id: _selectedTask!.id,
        task: editedTaskText,
        completed: _selectedTask!.completed,
      );
      final authService = ref.read(authServiceProvider);
      final token = await authService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retrieve authentication token')),
        );
        return;
      }
      try {
        await ref
            .read(tasksProvider.notifier)
            .updateTaskViaAPI(updatedTask, token);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated successfully')),
        );
        _toggleEditToDoWidget();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $error')),
        );
      }
    }
  }

  Future<void> _deleteTask(ToDo task) async {
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve authentication token')),
      );
      print(
          'Failed to delete task: No authentication token'); // Debug statement
      return;
    }

    try {
      // Delete task from the API
      print('Deleting task via API: ${task.id}'); // Debug statement
      await ref.read(tasksProvider.notifier).deleteTaskViaAPI(task.id, token);

      // Emit task deletion event via socket
      print('Emitting task deletion via socket: ${task.id}'); // Debug statement
      ref.read(socketServiceTasksProvider).emitTaskUpdate({
        '_id': task.id,
        'deleted': true,
      });

      // Notify the user
      print('Task deleted successfully: ${task.id}'); // Debug statement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${task.task} deleted')),
      );
    } catch (error) {
      print('Error deleting task: $error'); // Debug statement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $error')),
      );
    }
  }

  Future<void> _updateTask(ToDo task) async {
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve authentication token')),
      );
      return;
    }

    try {
      await ref.read(tasksProvider.notifier).updateTaskViaAPI(task, token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task updated successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $error')),
      );
    }
  }
}

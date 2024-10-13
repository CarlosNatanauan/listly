import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../providers/providers.dart';
import '../widgets/edit_todo_widget.dart';
import '../providers/fab_visibility_provider.dart';

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
        _buildSearchBar(),
        Expanded(
          child: Stack(
            children: [
              ListView(
                children: [
                  if (notCompletedTasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text('Not Completed', style: TextStyle(fontSize: 16)),
                    ),
                    ...notCompletedTasks
                        .map((task) => _buildTaskCard(context, task)),
                  ],
                  if (completedTasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                    // Only display completed tasks if the toggle is on
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
            style: TextStyle(
              fontSize: 14.0, // Reduced font size
            ),
            decoration: InputDecoration(
              labelText: 'Search Tasks',
              labelStyle:
                  TextStyle(fontSize: 14.0), // Adjust the label font size
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search,
                  size: 20.0, color: Colors.grey), // Smaller icon size
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                // No automatic change to _showCompletedTasks here
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
        await ApiService.updateTask(updatedTask, token);
        ref.read(tasksProvider.notifier).updateTask(updatedTask);

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
                      fontSize: 16,
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
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

  Future<void> _deleteTask(ToDo task) async {
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve authentication token')),
      );
      return;
    }

    try {
      await ApiService.deleteTask(task.id, token);
      ref.read(tasksProvider.notifier).removeTask(task.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${task.task} deleted')),
      );
    } catch (error) {
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
      await ApiService.updateTask(task, token);
      ref.read(tasksProvider.notifier).updateTask(task);

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

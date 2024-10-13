import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'notes_screen.dart';
import 'todo_screen.dart';
import '../widgets/add_todo_widget.dart'; // Import the AddToDoWidget
import '../widgets/add_note_widget.dart'; // Import Add Notes screen (placeholder)
import '../services/api_service.dart';
import '../providers/providers.dart';
import '../../models/todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert'; // For jsonDecode
import '../providers/fab_visibility_provider.dart'; // Import the FAB visibility provider

class MainPage extends ConsumerStatefulWidget {
  final String welcomeMessage;

  MainPage({required this.welcomeMessage});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;
  final double _bottomNavBarHeight = 55.0;
  bool _isAddToDoVisible = false;
  TextEditingController _toDoTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();

    if (token != null) {
      try {
        final List<dynamic> response = await ApiService.fetchTasks(token);

        if (response is List) {
          ref.read(tasksProvider.notifier).setTasks(
                response.map((taskJson) => ToDo.fromJson(taskJson)).toList(),
              );
        } else {
          throw Exception('Invalid response format');
        }
      } catch (error) {
        _showErrorSnackBar('Error fetching tasks: $error');
      }
    } else {
      _showErrorSnackBar('No authentication token found. Please log in.');
    }
  }

  void _toggleAddToDoWidget() {
    setState(() {
      _isAddToDoVisible = !_isAddToDoVisible;
    });
  }

  void _saveToDo() async {
    String newToDo = _toDoTextController.text.trim();
    if (newToDo.isNotEmpty) {
      final authService = ref.read(authServiceProvider);
      final token = await authService.getToken();

      if (token == null) {
        _showErrorSnackBar('No authentication token found. Please log in.');
        return;
      }

      try {
        final response = await ApiService.addTask(newToDo, token);
        final Map<String, dynamic> jsonResponse = jsonDecode(response);
        final ToDo newTask = ToDo.fromJson(jsonResponse);

        ref.read(tasksProvider.notifier).addTask(newTask);
        _toDoTextController.clear();
        _isAddToDoVisible = false;
      } catch (error) {
        _showErrorSnackBar('Error adding task: $error');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleFABPress() {
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddNotesWidget()),
      );
    } else if (_selectedIndex == 1) {
      _toggleAddToDoWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final isFABVisible =
        ref.watch(fabVisibilityProvider); // Listen to FAB visibility

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.welcomeMessage,
                  style: TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  print('Settings pressed');
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            _selectedIndex == 1
                ? tasks.isEmpty
                    ? Center(child: Text('No tasks available'))
                    : TodoScreen()
                : NotesScreen(),
            if (_isAddToDoVisible)
              AddToDoWidget(
                onClose: _toggleAddToDoWidget,
                textController: _toDoTextController,
                onSave: _saveToDo,
              ),
          ],
        ),
        floatingActionButton: (!_isAddToDoVisible && isFABVisible)
            ? FloatingActionButton(
                onPressed: _handleFABPress,
                child: Icon(Icons.add, color: Colors.white),
                backgroundColor: Color(0xFFFF725E),
                elevation: 5,
              )
            : null, // Hide FAB when edit or add widget is visible
        bottomNavigationBar: FlashyTabBar(
          height: _bottomNavBarHeight,
          selectedIndex: _selectedIndex,
          showElevation: true,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
              if (index != 1) {
                _isAddToDoVisible = false;
              }
            });
          },
          items: [
            FlashyTabBarItem(
              icon: Icon(Icons.note),
              title: Text('Notes'),
              inactiveColor: Color.fromARGB(255, 255, 218, 213),
              activeColor: Color(0xFFFF725E),
            ),
            FlashyTabBarItem(
              icon: Icon(Icons.check_circle),
              title: Text('To-do'),
              inactiveColor: Color.fromARGB(255, 255, 218, 213),
              activeColor: Color(0xFFFF725E),
            ),
          ],
        ),
      ),
    );
  }
}

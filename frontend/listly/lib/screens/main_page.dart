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

class MainPage extends ConsumerStatefulWidget {
  final String welcomeMessage;

  MainPage({required this.welcomeMessage});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0; // Initial tab index
  final double _bottomNavBarHeight = 55.0;
  final double _fabMargin = 40.0;
  bool _isAddToDoVisible = false; // Tracks visibility of AddToDoWidget
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
          // Update the tasks in the provider
          ref.read(tasksProvider.notifier).setTasks(
                response.map((taskJson) => ToDo.fromJson(taskJson)).toList(),
              );
        } else {
          throw Exception('Invalid response format');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tasks: ${error.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No authentication token found. Please log in.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No authentication token found. Please log in.')),
        );
        return;
      }

      try {
        // Send the new task to the backend and get the response
        final response = await ApiService.addTask(newToDo, token);

        // Parse the JSON response and convert it into a ToDo object
        final Map<String, dynamic> jsonResponse = jsonDecode(response);
        final ToDo newTask = ToDo.fromJson(jsonResponse);

        // If the task was added successfully, update the provider
        ref
            .read(tasksProvider.notifier)
            .addTask(newTask); // Update the provider with the new task
        _toDoTextController.clear(); // Clear the input field
        _isAddToDoVisible = false; // Hide the widget after saving

        // Show success message
        /*
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New task added successfully')),
        );
        */
      } catch (error) {
        // Handle any errors when adding the task
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $error')),
        );
      }
    }
  }

  // Handle the action for the floating action button
  void _handleFABPress() {
    if (_selectedIndex == 0) {
      // If Notes tab is selected, navigate to AddNotesWidget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddNotesWidget()),
      );
    } else if (_selectedIndex == 1) {
      // If To-do tab is selected, show AddToDoWidget
      _toggleAddToDoWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider); // Watch the tasks from the provider

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
            // Display the current tab content
            _selectedIndex == 1
                ? tasks.isEmpty
                    ? Center(child: Text('No tasks available'))
                    : TodoScreen() // Pass the tasks from the provider
                : NotesScreen(),

            // Show AddToDoWidget if it's visible
            if (_isAddToDoVisible)
              AddToDoWidget(
                onClose: _toggleAddToDoWidget,
                textController: _toDoTextController,
                onSave: _saveToDo,
              ),
          ],
        ),

        // Conditionally show the FAB when AddToDoWidget is not visible
        floatingActionButton: !_isAddToDoVisible
            ? FloatingActionButton(
                onPressed: _handleFABPress,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Color(0xFFFF725E),
                elevation: 5,
              )
            : null,

        bottomNavigationBar: FlashyTabBar(
          height: _bottomNavBarHeight,
          selectedIndex: _selectedIndex,
          showElevation: true,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
              if (index != 1) {
                _isAddToDoVisible =
                    false; // Hide AddToDoWidget if not in To-do tab
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

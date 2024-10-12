import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import to handle system navigation
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart'; // Import flashy_tab_bar2
import 'notes_screen.dart'; // Import your NotesScreen
import 'todo_screen.dart'; // Import your TodoScreen
import '../services/api_service.dart';
import '../providers/providers.dart';

import '../../models/todo.dart'; // Import your ToDo model
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

class MainPage extends ConsumerStatefulWidget {
  final String welcomeMessage;

  MainPage({required this.welcomeMessage});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0; // Initial tab index
  final double _bottomNavBarHeight =
      55.0; // Height of the bottom navigation bar
  final double _fabMargin = 40.0; // Margin above the bottom navigation bar

  List<ToDo> _tasks = []; // State variable for tasks
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // Fetch tasks when the app starts
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();

    if (token != null) {
      try {
        final List<dynamic> response = await ApiService.fetchTasks(token);

        // Ensure the response is not null and is a List
        if (response is List) {
          setState(() {
            _tasks = response
                .map((taskJson) => ToDo.fromJson(taskJson))
                .toList(); // Store tasks
            _isLoading = false; // Stop loading
          });
        } else {
          throw Exception('Invalid response format');
        }
      } catch (error) {
        setState(() {
          _isLoading = false; // Stop loading on error
        });
        print('Error fetching tasks: $error'); // Log the actual error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tasks: ${error.toString()}')),
        );
      }
    } else {
      setState(() {
        _isLoading = false; // Stop loading if no token
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No authentication token found. Please log in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Exit the app when back button is pressed
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // No back button
          title: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space title and icon
            children: [
              Expanded(
                child: Text(
                  widget.welcomeMessage, // Show welcome message as title
                  style: TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis, // Ellipsis for long text
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  // Handle settings action here
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
                ? _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TodoScreen(tasks: _tasks) // Pass the tasks to TodoScreen
                : NotesScreen(), // Show NotesScreen if index is 0
            Positioned(
              right: 10, // Right margin
              bottom: _bottomNavBarHeight -
                  _fabMargin, // Position above the bottom nav bar
              child: FloatingActionButton(
                onPressed: () {
                  // Handle button press
                  print('Add button pressed');
                },
                child: Icon(Icons.add),
                backgroundColor:
                    Color(0xFFFF725E), // Custom color for the button
                elevation: 5, // Optional: Shadow for the button
              ),
            ),
          ],
        ),
        bottomNavigationBar: FlashyTabBar(
          height:
              _bottomNavBarHeight, // Set height of the bottom navigation bar
          selectedIndex: _selectedIndex,
          showElevation: true, // Add shadow/elevation
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index; // Update selected index
            });
          },
          items: [
            FlashyTabBarItem(
              icon: Icon(Icons.note), // Notes icon
              title: Text('Notes'),
              inactiveColor: Color.fromARGB(255, 255, 218, 213),
              activeColor: Color(0xFFFF725E), // Updated active color
            ),
            FlashyTabBarItem(
              icon: Icon(Icons.check_circle), // To-do icon
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

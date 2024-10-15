import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'notes_screen.dart';
import 'todo_screen.dart';
import '../widgets/add_todo_widget.dart';
import '../widgets/add_note_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fab_visibility_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/socket_service_provider.dart'; // Import your socketServiceProvider
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_providers.dart'; // Add this import

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
  String? _token; // Variable to store the token
  bool _isSocketConnected = false; // To track socket connection status

  @override
  void initState() {
    super.initState();
    _fetchTokenAndTasks(); // Fetch token and tasks together
  }

  Future<void> _fetchTokenAndTasks() async {
    final authService = ref.read(authServiceProvider);
    String? token = await authService.getToken();

    if (token != null) {
      _token = token; // Store the fetched token
      _initializeSocketConnection(); // Initialize socket after token is fetched
      _fetchTasks(); // Fetch tasks after token is available
    } else {
      _showErrorSnackBar('No authentication token found. Please log in.');
    }
  }

  void _initializeSocketConnection() {
    final socketService = ref.read(socketServiceProvider);
    if (_token != null && !_isSocketConnected) {
      socketService.connect(_token!, (updatedNote) {
        // Whenever a note is updated, fetch the latest notes
        ref.read(notesProvider(_token!).notifier).fetchNotes();
      });
      _isSocketConnected = true; // Mark the socket as connected
    } else {
      print('No valid token, cannot connect to socket.');
    }
  }

  Future<void> _fetchTasks() async {
    if (_token != null) {
      try {
        await ref.read(tasksProvider.notifier).fetchTasks(_token!);
      } catch (error) {
        _showErrorSnackBar(error.toString());
      }
    }
  }

  @override
  void dispose() {
    _toDoTextController.dispose();
    ref
        .read(socketServiceProvider)
        .disconnect(); // Disconnect socket when page is disposed
    super.dispose();
  }

  void _toggleAddToDoWidget() {
    setState(() {
      _isAddToDoVisible = !_isAddToDoVisible;
    });
  }

  void _saveToDo() async {
    String newToDo = _toDoTextController.text.trim();
    if (newToDo.isNotEmpty) {
      if (_token == null) {
        _showErrorSnackBar('No authentication token found. Please log in.');
        return;
      }

      try {
        await ref.read(tasksProvider.notifier).addTaskViaAPI(newToDo, _token!);
        _toDoTextController.clear();
        _isAddToDoVisible = false;
      } catch (error) {
        _showErrorSnackBar(error.toString());
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
      if (_token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddNoteWidget()),
        );
      } else {
        _showErrorSnackBar('No authentication token found. Please log in.');
      }
    } else if (_selectedIndex == 1) {
      _toggleAddToDoWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final isFABVisible = ref.watch(fabVisibilityProvider);

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
                icon: Icon(
                  Icons.settings,
                  color: Color(0xFFFF725E),
                ),
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
                : _token != null
                    ? NotesScreen(token: _token!) // Use the stored token
                    : Center(
                        child: Text('Token is not available. Please log in.')),
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
            : null,
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

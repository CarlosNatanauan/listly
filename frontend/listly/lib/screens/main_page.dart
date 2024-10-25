import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'notes_screen.dart';
import 'todo_screen.dart';
import '../widgets/add_todo_widget.dart';
import '../widgets/add_note_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fab_visibility_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/socket_service_provider.dart';
import '../providers/socket_service_tasks_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_providers.dart'; // Add this import
import '../dialogs/logout_confirmation_dialog.dart';
import 'session_expired_screen.dart'; // Import for session expiration redirection
import '../screens/main_page_screens/account_screen.dart';
import '../screens/main_page_screens/settings_screen.dart';
import '../screens/main_page_screens/about_screen.dart';

class MainPage extends ConsumerStatefulWidget {
  final String userName;

  MainPage({required this.userName});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0; // To keep track of the selected tab
  final double _bottomNavBarHeight =
      55.0; // Height of the bottom navigation bar
  bool _isAddToDoVisible = false; // State for the Add ToDo widget visibility
  TextEditingController _toDoTextController =
      TextEditingController(); // Controller for ToDo input
  String? _token; // Authentication token
  bool _isSocketConnected = false; // Socket connection state
  Timer? _tokenValidationTimer; // Timer to periodically check token validity

  final _zoomDrawerController =
      ZoomDrawerController(); // Initialize ZoomDrawerController

  @override
  void initState() {
    super.initState();
    _fetchTokenAndData(); // Fetch token and notes/tasks
    _startTokenValidationTimer(); // Start periodic token validation
  }

  Future<void> _fetchTokenAndData() async {
    final authService = ref.read(authServiceProvider);
    String? token = await authService.getToken();

    if (token != null) {
      _token = token;

      print("Token is set: $_token");

      // Reinitialize both sockets for notes and tasks with fresh token
      ref.read(socketServiceProvider).disconnect();
      ref.read(socketServiceTasksProvider).disconnect();

      _isSocketConnected = false;
      _initializeSocketConnection();
      _fetchTasks(); // Fetch tasks

      // After token is set, use Navigator to reload the MainPage
    } else {
      _showErrorSnackBar('No authentication token found. Please log in.');
    }
  }

  // Method to start a timer that periodically checks token validity (20 seconds)
  void _startTokenValidationTimer() {
    _tokenValidationTimer =
        Timer.periodic(Duration(seconds: 20), (timer) async {
      final authService = ref.read(authServiceProvider);
      if (_token != null) {
        bool isValid = await authService.isTokenValid(_token!);
        if (!isValid) {
          _handleSessionExpired();
        }
      }
    });
  }

  // Handle session expiration: log out the user and navigate to session expired screen
  void _handleSessionExpired() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SessionExpiredScreen()),
      (route) => false,
    );
    ref.read(authServiceProvider).logout(); // Perform logout
  }

  void _initializeSocketConnection() {
    final socketService = ref.read(socketServiceProvider);
    if (_token != null) {
      socketService.connect(_token!, (updatedNote) {
        ref
            .read(notesProvider(_token!).notifier)
            .fetchNotes(); // Ensure refetching notes on update
      });
      _isSocketConnected = true;
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
    _tokenValidationTimer?.cancel(); // Cancel the token validation timer
    _toDoTextController.dispose();

    // Disconnect both notes and tasks socket services when disposing the page
    ref.read(socketServiceProvider).disconnect(); // Notes socket
    ref.read(socketServiceTasksProvider).disconnect(); // Tasks socket
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
      child: ZoomDrawer(
        menuBackgroundColor: Color.fromARGB(255, 255, 139, 124),
        controller: _zoomDrawerController,
        style: DrawerStyle.defaultStyle, // Change to desired style
        menuScreen: MenuScreen(
          onMenuItemTap: (index) {
            setState(() {
              _selectedIndex = index; // Update the selected index
            });
            _zoomDrawerController.toggle?.call(); // Close the drawer
          },
        ),
        mainScreen: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromARGB(248, 248, 248, 248),
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Hello, ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 97, 93, 93),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '${widget.userName}',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xFFFF725E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      try {
                        _zoomDrawerController.toggle?.call();
                      } catch (e) {
                        print('Error toggling drawer: $e');
                        _showErrorSnackBar('Error: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                // Notes and Tasks conditional loading
                _selectedIndex == 1
                    ? tasks.isEmpty
                        ? Center(child: Text('No tasks available'))
                        : TodoScreen()
                    : _token != null && _token!.isNotEmpty
                        ? NotesScreen(token: _token!)
                        : Center(
                            child: CircularProgressIndicator(),
                          ), // Show loader until token is available

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
                  if (index == 0) {
                    // **Fetch notes again when Notes tab is selected**
                    if (_token != null) {
                      ref.read(notesProvider(_token!).notifier).fetchNotes();
                    }
                  }
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
            )),
        borderRadius: 24.0,
        showShadow: true,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.bounceIn,
      ),
    );
  }
}

class MenuScreen extends ConsumerWidget {
  final Function(int) onMenuItemTap;

  MenuScreen({required this.onMenuItemTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Color(0xFFFF725E),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 30, 8, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    ZoomDrawer.of(context)?.toggle();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            _buildMenuItem(Icons.account_circle, 'Account', 0, context, ref),
            _buildMenuItem(Icons.settings, 'Settings', 1, context, ref),
            _buildMenuItem(Icons.info, 'About', 2, context, ref),
            Spacer(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 245, 86, 65),
                child: ListTile(
                  leading:
                      Icon(Icons.exit_to_app, color: Colors.white, size: 24),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    showLogoutConfirmationDialog(context, ref);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index,
      BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFFF725E),
        child: ListTile(
          leading: Icon(icon, color: Colors.white, size: 24),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          onTap: () async {
            final authService = ref.read(authServiceProvider);
            final user = authService.currentUser; // Get the current user
            final token = await authService.getToken(); // Fetch the token

            if (index == 0 && user != null && token != null) {
              // Ensure the user is logged in and token is available before navigating to AccountScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AccountScreen(
                    username: user.username, // Pass the username
                    email: user.email, // Pass the email
                    token: token, // Pass the token
                  ),
                ),
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            }
            onMenuItemTap(
                index); // Notify parent widget about the selected menu item
          },
        ),
      ),
    );
  }
}

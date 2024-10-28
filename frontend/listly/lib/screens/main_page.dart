// Dart & Flutter SDK
import 'dart:async';

// Flutter packages
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Screens
import '../screens/main_page_screens/about_screen.dart';
import '../screens/main_page_screens/account_screen.dart';
import '../screens/main_page_screens/settings_screen.dart';
import 'notes_screen.dart';
import 'session_expired_screen.dart';
import 'todo_screen.dart';

// Providers
import '../providers/auth_providers.dart';
import '../providers/connectivity_provider.dart';
import '../providers/fab_visibility_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/socket_service_provider.dart';
import '../providers/socket_service_tasks_provider.dart';
import '../providers/tasks_provider.dart';

// Widgets
import '../widgets/add_note_widget.dart';
import '../widgets/add_todo_widget.dart';

// Dialogs
import '../dialogs/logout_confirmation_dialog.dart';

class MainPage extends ConsumerStatefulWidget {
  final String userName;

  MainPage({required this.userName});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;
  final double _bottomNavBarHeight = 55.0;
  bool _isAddToDoVisible = false;
  TextEditingController _toDoTextController = TextEditingController();
  String? _token;
  bool _isSocketConnected = false;
  Timer? _tokenValidationTimer;
  final _zoomDrawerController = ZoomDrawerController();
  bool _isListening = false;
  bool _isRetryingConnection = false; // Flag to prevent multiple retry attempts
  bool _loadingAfterReconnect =
      false; // Suppresses error messages during reconnect attempts

  @override
  void initState() {
    super.initState();
    _fetchTokenAndData();
    _startTokenValidationTimer();
  }

  Future<void> _fetchTokenAndData({bool isRetry = false}) async {
    final connectivityStatus =
        await Connectivity().checkConnectivity(); // Explicit connectivity check
    if (connectivityStatus == ConnectivityResult.none) {
      if (!isRetry && !_loadingAfterReconnect) {
        _showErrorSnackBar(
            'No internet connection. Please check your connection.');
      }
      return;
    }

    final authService = ref.read(authServiceProvider);
    String? token = await authService.getToken();

    if (token != null) {
      _token = token;
      print("Token is set: $_token");

      ref.read(socketServiceProvider).disconnect();
      ref.read(socketServiceTasksProvider).disconnect();

      _isSocketConnected = false;
      _initializeSocketConnection();
      await _fetchTasks(
          isRetry: isRetry); // Suppress initial error message on retry
    } else {
      _showErrorSnackBar('No authentication token found. Please log in.');
    }
  }

  Future<void> _fetchTasks({bool isRetry = false}) async {
    final connectivityStatus = await Connectivity().checkConnectivity();
    if (connectivityStatus == ConnectivityResult.none) {
      if (!_loadingAfterReconnect) {
        _showErrorSnackBar('No internet connection. Unable to fetch tasks.');
      }
      return;
    }

    if (_token != null) {
      try {
        await ref.read(tasksProvider.notifier).fetchTasks(_token!);
        _loadingAfterReconnect = false; // Reset after successful fetch
      } catch (error) {
        if (isRetry && !_loadingAfterReconnect) {
          _showErrorSnackBar(error.toString());
        }
      }
    }
  }

  // Start token validation timer
  void _startTokenValidationTimer() {
    _tokenValidationTimer =
        Timer.periodic(Duration(seconds: 20), (timer) async {
      final connectivityStatus = ref.read(connectivityProvider).value;
      if (connectivityStatus != ConnectivityResult.none && _token != null) {
        final authService = ref.read(authServiceProvider);
        bool isValid = await authService.isTokenValid(_token!);
        if (!isValid) {
          _handleSessionExpired();
        }
      }
    });
  }

  // Stop token validation timer
  void _stopTokenValidationTimer() {
    _tokenValidationTimer?.cancel();
  }

  // Handle session expiration
  void _handleSessionExpired() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SessionExpiredScreen()),
      (route) => false,
    );
    ref.read(authServiceProvider).logout();
  }

  // Initialize socket connection for notes
  void _initializeSocketConnection() {
    final socketService = ref.read(socketServiceProvider);
    if (_token != null) {
      socketService.connect(_token!, (updatedNote) {
        ref.read(notesProvider(_token!).notifier).fetchNotes();
      });
      _isSocketConnected = true;
    } else {
      print('No valid token, cannot connect to socket.');
    }
  }

  void _handleConnectivityRestoration() async {
    print("Internet connection restored: attempting to re-fetch data");

    if (_isRetryingConnection) return;
    _isRetryingConnection = true;
    _loadingAfterReconnect = true; // Suppress error messages

    int retryCount = 0;
    const maxRetries = 3;
    const initialDelay = 2; // in seconds

    while (retryCount < maxRetries) {
      await Future.delayed(Duration(
          seconds: initialDelay * (1 << retryCount))); // Exponential backoff
      final connectivityStatus = await Connectivity().checkConnectivity();

      if (connectivityStatus != ConnectivityResult.none) {
        try {
          await Future.delayed(Duration(
              seconds: 3)); // Add 3-second delay before validating token
          await _fetchTokenAndData(
              isRetry: true); // Attempt to fetch data after restoration
          _startTokenValidationTimer(); // Restart the timer if it was stopped
          _loadingAfterReconnect =
              false; // Reset loading state after successful fetch
          print(
              "Tasks and notes successfully re-fetched after internet restoration.");
          break;
        } catch (error) {
          print(
              "Retry $retryCount: Error fetching data after connectivity restoration: $error");
          if (retryCount == maxRetries - 1) {
            _showErrorSnackBar(
                "Error loading data after reconnecting. Please try again.");
          }
          retryCount++;
        }
      } else {
        print("Retry $retryCount: No connectivity detected on retry.");
        retryCount++;
      }
    }
    _isRetryingConnection = false;
  }

  // Stop timer and handle connectivity loss
  void _handleConnectivityLoss() {
    _stopTokenValidationTimer(); // Stop the timer
    print("Internet connection lost: Timer stopped");
  }

  @override
  void dispose() {
    _stopTokenValidationTimer();
    _toDoTextController.dispose();
    ref.read(socketServiceProvider).disconnect();
    ref.read(socketServiceTasksProvider).disconnect();
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

    // Listen for connectivity changes, stopping and starting the timer as needed
    if (!_isListening) {
      _isListening = true;
      ref.listen<AsyncValue<ConnectivityResult>>(connectivityProvider,
          (previous, next) {
        if (next.value == ConnectivityResult.none) {
          _handleConnectivityLoss();
        } else {
          _handleConnectivityRestoration();
        }
      });
    }

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: ZoomDrawer(
        menuBackgroundColor: Color.fromARGB(255, 255, 139, 124),
        controller: _zoomDrawerController,
        style: DrawerStyle.defaultStyle,
        menuScreen: MenuScreen(
          onMenuItemTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _zoomDrawerController.toggle?.call();
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
                _selectedIndex == 1
                    ? TodoScreen()
                    : _token != null && _token!.isNotEmpty
                        ? NotesScreen(token: _token!)
                        : Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Color(
                                  0xFFFF725E), // Set to a color that matches your app theme
                              size: 50,
                            ),
                          ),
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
                  if (index == 0 && _token != null) {
                    ref.read(notesProvider(_token!).notifier).fetchNotes();
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
              // Navigate to AccountScreen with user and token
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AccountScreen(
                    username: user.username, // Pass the username
                    email: user.email, // Pass the email
                    token: token, // Pass the token
                  ),
                ),
              );
            } else if (index == 1 && user != null && token != null) {
              print(
                  "Navigating to SettingsScreen with email: ${user.email} and token: $token");

              // Navigate to SettingsScreen with token and email
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    email: user.email, // Use the non-null email
                    token: token, // Use the non-null token
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            } else {
              // Show an error if token or email is missing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Authentication details are missing.')),
              );
            }
          },
        ),
      ),
    );
  }
}

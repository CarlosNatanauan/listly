import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import to handle system navigation
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart'; // Import flashy_tab_bar2

class MainPage extends StatefulWidget {
  final String welcomeMessage;

  MainPage({required this.welcomeMessage});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Initial tab index
  final double _bottomNavBarHeight =
      55.0; // Height of the bottom navigation bar
  final double _fabMargin = 10.0; // Margin above the bottom navigation bar

  // Define widgets for each tab
  final List<Widget> _pages = [
    Center(child: Text('Notes Page')), // Notes Page
    Center(child: Text('To-do Page')), // To-do Page
  ];

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
            _pages[_selectedIndex], // Display the current tab content
            Positioned(
              right: 10, // Right margin
              bottom:
                  _bottomNavBarHeight - 40, // Position above the bottom nav bar
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

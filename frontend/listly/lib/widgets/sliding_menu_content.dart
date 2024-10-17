import 'package:flutter/material.dart';

class SlidingMenuContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the menu when tapping outside
      },
      child: Stack(
        children: [
          // Transparent background to capture tap
          Container(
            color: Colors.transparent,
          ),
          Align(
            alignment: Alignment.centerRight, // Align the content to the right
            child: FractionallySizedBox(
              widthFactor: 0.7, // Adjust the width factor (70% of screen)
              child: Material(
                elevation: 8,
                child: Container(
                  padding:
                      const EdgeInsets.fromLTRB(8.0, 46.0, 0, 0), // Add padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title at the top
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Listly', // Title Text
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF725E), // Title color
                          ),
                        ),
                      ),
                      // List of menu items
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Account'),
                        onTap: () {
                          Navigator.pop(context); // Close the sliding menu
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: () {
                          Navigator.pop(context); // Close the sliding menu
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About'),
                        onTap: () {
                          Navigator.pop(context); // Close the sliding menu
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

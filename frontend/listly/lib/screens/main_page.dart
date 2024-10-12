import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart'; // Ensure this file exports your userProvider

class MainPage extends StatelessWidget {
  final String welcomeMessage;

  MainPage({required this.welcomeMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: Center(
        child: Text(
          welcomeMessage,
          style: TextStyle(
              fontSize:
                  24), // Optional: Increase font size for better visibility
        ),
      ),
    );
  }
}

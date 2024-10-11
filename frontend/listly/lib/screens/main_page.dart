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
      ),
      body: Center(
        child: Text(welcomeMessage),
      ),
    );
  }
}

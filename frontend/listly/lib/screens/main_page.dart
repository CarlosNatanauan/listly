import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart'; // Ensure this file exports your userProvider

class MainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Text(
          user != null
              ? 'Hello, User ID: ${user.id}'
              : 'Hello, Guest', // Changed to display user ID
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../main_page.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // State to manage loading

  void _login() async {
    final username = _usernameController.text.trim(); // Trim whitespace
    final password = _passwordController.text.trim();

    print(
        'Attempting to log in with Username: $username and Password: $password');

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    // Access AuthService via Riverpod
    final authService = ref.read(authServiceProvider);
    final user = await authService.login(username, password);

    setState(() {
      _isLoading = false; // Set loading state to false
    });

    if (user != null) {
      ref.read(userProvider.notifier).state = user; // Update user provider
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => MainPage()), // Navigate to MainPage
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid username or password'), // Show error message
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_isLoading) // Show loading indicator while logging in
              CircularProgressIndicator(),
            ElevatedButton(
              onPressed:
                  _isLoading ? null : _login, // Disable button if loading
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

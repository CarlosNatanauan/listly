import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../main_page.dart';
import 'register_screen.dart';
import '../../providers/auth_providers.dart'; // Import the providers

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // State to manage password visibility

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    final authService = ref.read(authServiceProvider); // Access authService
    final user = await authService.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      ref.read(userProvider.notifier).state = user; // Update user state
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              MainPage(welcomeMessage: 'Welcome back, ${user.username}!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid username or password'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Remove the AppBar shadow if desired
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
        title: null, // Remove the title from the AppBar
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 30.0), // Padding similar to OnboardingScreen
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image at the top
                Image.asset(
                  'assets/images/login_image.png', // Replace with your image asset
                  width: screenWidth * 0.6, // Responsive width
                  height: screenHeight * 0.32, // Responsive height
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30), // Space between image and text
                // Big Login Text
                Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                SizedBox(height: 10), // Space between texts
                // Username TextField
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      // Add border style
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Color(0xFFFF725E)), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Color(0xFFFF725E)), // Focused border color
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0), // Padding inside TextField
                  ),
                ),
                SizedBox(height: 10), // Space between text fields
                // Password TextField with reveal password icon
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      // Add border style
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Color(0xFFFF725E)), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Color(0xFFFF725E)), // Focused border color
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible =
                              !_isPasswordVisible; // Toggle password visibility
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0), // Padding inside TextField
                  ),
                  obscureText: !_isPasswordVisible, // Show/hide password
                ),
                SizedBox(height: 20), // Space before button
                if (_isLoading)
                  CircularProgressIndicator(), // Loading indicator
                SizedBox(height: 20), // Space before button
                // Login button
                SizedBox(
                  width: screenWidth * 0.8, // Set width based on screen width
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF725E), // Custom color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(
                          vertical: 13.0), // Same vertical padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded edges
                      ),
                      elevation: 5, // Shadow effect
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 20), // Consistent text size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

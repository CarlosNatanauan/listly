import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main_page.dart';
import '../../providers/auth_providers.dart'; // Import the providers
import '../../change_password/forgot_password.dart';

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
          builder: (context) => MainPage(userName: '${user.username}!'),
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
              vertical: 30.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image at the top
                Image.asset(
                  'assets/images/login_image.png',
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.22,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30), // Space between image and text
                // Big Login Text
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 10), // Space between texts
                // Username TextField
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: 10), // Space between text fields
                // Password TextField with reveal password icon
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFFF725E)),
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
                      horizontal: 16.0,
                    ),
                  ),
                  obscureText: !_isPasswordVisible, // Show/hide password
                ),
                // Forgot Password Text Button
                Align(
                  alignment: Alignment.centerRight, // Align to the right
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                      // Print statement
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFFFF725E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  CircularProgressIndicator(), // Loading indicator
                SizedBox(height: 10), // Space before button
                // Login button
                SizedBox(
                  width: screenWidth * 0.8, // Set width based on screen width
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF725E), // Custom color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(
                        vertical: 13.0,
                      ), // Same vertical padding
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

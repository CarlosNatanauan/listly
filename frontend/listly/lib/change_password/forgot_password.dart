import 'package:flutter/material.dart';
import './otp_request.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword(BuildContext context) {
    final email = _emailController.text.trim();
    print('Reset password for email: $email'); // For debugging
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center align the items
              children: [
                SizedBox(height: screenHeight * 0.05), // Adjust the top spacing
                // Image at the center
                Image.asset(
                  'assets/images/forgot_password.png', // Replace with your image asset
                  width: screenWidth * 0.5, // Responsive width
                  height: screenHeight * 0.25, // Responsive height
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30), // Space between image and text
                // Big Forgot Password Text
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 10), // Space between texts
                // Small Instruction Text
                Text(
                  "No worries, we'll send you reset instructions.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 20), // Space before email TextField
                // Email TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
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
                      horizontal: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: 20), // Space before Reset button
                // Reset Password button
                SizedBox(
                  width: screenWidth * 0.8, // Set width based on screen width
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OTPRequestScreen(
                              email: _emailController.text.trim()),
                        ),
                      );
                    }, // Call reset password method
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF725E), // Custom color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(
                        vertical: 13.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded edges
                      ),
                      elevation: 5, // Shadow effect
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 20), // Consistent text size
                    ),
                  ),
                ),
                SizedBox(height: 20), // Space before back to login
                // Back to Login clickable text
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to login
                  },
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the row
                    children: [
                      Icon(Icons.arrow_back,
                          color: Color(0xFFFF725E)), // Back arrow icon
                      SizedBox(width: 5), // Space between icon and text
                      Text(
                        'Back to Log in',
                        style: TextStyle(
                          color: Color(0xFFFF725E),
                          fontSize: 14,
                        ),
                      ),
                    ],
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

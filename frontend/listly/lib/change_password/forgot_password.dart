import 'package:flutter/material.dart';
import './otp_request.dart';
import '../services/api_service.dart';
import '../dialogs/loading_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _validationMessage = ''; // To hold validation messages
  bool _isValidEmail = false; // Track if the email is valid

  Future<void> _resetPassword(BuildContext context) async {
    final email = _emailController.text.trim();
    print('Reset password for email: $email'); // For debugging

    // Show loading dialog with a more professional message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoadingDialog(message: 'Sending OTP...');
      },
    );

    try {
      // Call the API to request OTP
      final response = await ApiService.requestOtp(email);

      // Close the loading dialog after API call
      Navigator.of(context).pop(); // Close the loading dialog

      // If successful, navigate to OTPRequestScreen
      if (response['message'] == 'OTP sent') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPRequestScreen(email: email),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if an error occurs
      Navigator.of(context).pop();

      // Handle errors
      String errorMessage = e.toString();
      if (errorMessage.contains('User not found')) {
        _showDialog(context, 'Email Not Found',
            'No account is associated with this email. Please check your email and try again.');
      } else if (errorMessage.contains('daily OTP request limit')) {
        _showDialog(context, 'Request Limit Exceeded',
            'You have reached the maximum number of OTP requests for today. Please try again tomorrow.');
      } else {
        _showDialog(context, 'Error',
            'An unexpected error occurred. Please try again later.');
      }
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Color(0xFFFF725E))),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Color(0xFFFF725E))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _validateEmail(String value) {
    // Simple email validation using regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    setState(() {
      if (value.isEmpty) {
        _validationMessage = ''; // No message for empty input
        _isValidEmail = false;
      } else if (!emailRegex.hasMatch(value)) {
        _validationMessage = 'Please make sure the email address is valid';
        _isValidEmail = false;
      } else {
        _validationMessage = 'Email is valid';
        _isValidEmail = true;
      }
    });
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05),
                Image.asset(
                  'assets/images/forgot_password.png',
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.25,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30),
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "No worries, we'll send you reset instructions.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Email TextField
                TextField(
                  controller: _emailController,
                  onChanged: _validateEmail, // Validate email on change
                  decoration: InputDecoration(
                    labelText: 'Email',
                    floatingLabelStyle: TextStyle(color: Color(0xFFFF725E)),
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
                SizedBox(height: 5),
                // Validation message
                Text(
                  _validationMessage,
                  style: TextStyle(
                    color: _isValidEmail ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                // Reset Password button
                SizedBox(
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    onPressed: _isValidEmail
                        ? () {
                            _resetPassword(
                                context); // Call reset password method
                          }
                        : null, // Disable button if email is invalid
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValidEmail
                          ? Color(0xFFFF725E)
                          : Colors.grey, // Change color based on validity
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 13.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 20),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, color: Color(0xFFFF725E)),
                      SizedBox(width: 5),
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

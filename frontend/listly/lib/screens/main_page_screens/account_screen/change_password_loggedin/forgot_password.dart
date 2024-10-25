import 'package:flutter/material.dart';
import 'otp_request.dart';
import '../../../../services/api_service.dart';
import '../../../../dialogs/loading_dialog.dart'; // Import the loading dialog
import '../../account_screen.dart';
import '../../../../providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreenInside extends ConsumerStatefulWidget {
  final String email; // Accept email as a parameter

  ForgotPasswordScreenInside({required this.email});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreenInside> {
  late TextEditingController _emailController; // Initialize in initState
  String _validationMessage = ''; // To hold validation messages

  @override
  void initState() {
    super.initState();
    // Initialize the _emailController with the passed email
    _emailController = TextEditingController(text: widget.email);
  }

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
            builder: (context) => OTPRequestScreenInside(email: email),
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
                  'assets/images/forgot_password.png', // Replace with your image asset
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.25,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30),
                Text(
                  'Want to change Password?',
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
                  enabled: false, // Disable the TextField
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
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      _resetPassword(context); // Call reset password method
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF725E),
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
                      'Change Password',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Space before back to Account
                // Back to Account clickable text
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true); // Confirm and close dialog

                    final authService = ref.read(authServiceProvider);
                    final user = authService.currentUser;
                    final token = await authService.getToken(); // Fetch token

                    if (user != null && token != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(
                            username: user.username, // Pass username
                            email: user.email, // Pass email
                            token: token, // Pass token
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No user is logged in')),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, color: Color(0xFFFF725E)),
                      SizedBox(width: 5),
                      Text(
                        'Back to Account',
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

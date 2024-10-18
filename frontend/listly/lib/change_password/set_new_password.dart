import 'package:flutter/material.dart';

class SetNewPasswordScreen extends StatefulWidget {
  @override
  _SetNewPasswordScreenState createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isButtonEnabled = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      // Check if passwords match
      if (_passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty) {
        if (_passwordController.text == _confirmPasswordController.text) {
          _isButtonEnabled = true; // Enable button if passwords match
          _errorText = null; // Clear error text
        } else {
          _isButtonEnabled = false; // Disable button if passwords do not match
          _errorText = 'Passwords do not match'; // Set error text
        }
      } else {
        _isButtonEnabled = false; // Disable button if fields are empty
        _errorText = null; // Clear error text
      }
    });
  }

  void _resetPassword() {
    final password = _passwordController.text;
    print('Password reset to: $password'); // For debugging
    // Add logic for password reset here
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    final screenWidth = MediaQuery.of(context).size.width;

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
              children: [
                SizedBox(height: 60),
                // Encapsulated password input section
                PasswordInputSection(
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  errorText: _errorText,
                  isButtonEnabled: _isButtonEnabled,
                  onPasswordChange: _validatePasswords,
                ),
                SizedBox(height: 20), // Space before Reset Password button
                // Reset Password button
                SizedBox(
                  width: screenWidth * 0.8, // Set width based on screen width
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _resetPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF725E), // Custom color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(vertical: 13.0),
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
                SizedBox(height: 20), // Space before back to login text
                // Back to Login clickable text
                TextButton(
                  onPressed: () {
                    print('Back to login clicked');
                    Navigator.of(context)
                        .pop(); // Navigate back to the login screen
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

class PasswordInputSection extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? errorText;
  final bool isButtonEnabled;
  final VoidCallback onPasswordChange;

  const PasswordInputSection({
    Key? key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.errorText,
    required this.isButtonEnabled,
    required this.onPasswordChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align
      children: [
        // Image at the center
        Image.asset(
          'assets/images/set_new_password.png', // Image asset
          width: screenWidth * 0.5, // Responsive width
          height: screenHeight * 0.25, // Responsive height
          fit: BoxFit.fill,
        ),
        SizedBox(height: 30), // Space between image and text
        // Password requirement text
        Text(
          'Must be 8 characters long',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20), // Space before password fields
        // Password input field
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          obscureText: true, // Hide password input
          onChanged: (_) =>
              onPasswordChange(), // Call the validation function on change
        ),
        SizedBox(height: 20), // Space before confirm password field
        // Confirm Password input field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true, // Hide password input
              onChanged: (_) =>
                  onPasswordChange(), // Call the validation function on change
            ),
            if (errorText != null) // Show error text if passwords don't match
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorText!,
                  style: TextStyle(color: Colors.red), // Error text style
                ),
              ),
          ],
        ),
      ],
    );
  }
}

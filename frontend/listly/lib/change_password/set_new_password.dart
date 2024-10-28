import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../dialogs/loading_dialog.dart';
import '../screens/auth/login_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;

  SetNewPasswordScreen({required this.email});

  @override
  _SetNewPasswordScreenState createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isButtonEnabled = false;
  String? _errorText;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      if (_passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty) {
        if (_passwordController.text == _confirmPasswordController.text) {
          _isButtonEnabled = true;
          _errorText = null;
        } else {
          _isButtonEnabled = false;
          _errorText = 'Passwords do not match';
        }
      } else {
        _isButtonEnabled = false;
        _errorText = null;
      }
    });
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    print("Attempting to reset password for email: ${widget.email}");

    showDialog(
      context: context,
      builder: (context) => LoadingDialog(message: "Changing password..."),
    );

    try {
      print("Calling API with email: ${widget.email} and password: $password");
      await ApiService.changePassword(widget.email, password);
      Navigator.of(context).pop(); // Dismiss loading dialog
      _showSuccessDialog("Password changed successfully!");
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      print("Error occurred: $e"); // Print the error for debugging

      // Check if the error message matches the backend response
      if (e
          .toString()
          .contains("You can only change your password once every 24 hours.")) {
        _showErrorDialog(
            "Error", "You can only change your password once every 24 hours.");
      } else {
        _showErrorDialog("Error", e.toString());
      }
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the success dialog
              Navigator.of(context).pop(); // Go back to the previous screen

              // Navigate to the login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String title, String content) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the error dialog
              // Navigate to the login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Leave Password Change?"),
            content: Text(
              "Are you sure you want to leave this session? Your progress might be lost.",
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Dismiss dialog
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Dismiss dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ); // Navigate to LoginScreen
                },
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  PasswordInputSection(
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    errorText: _errorText,
                    isButtonEnabled: _isButtonEnabled,
                    onPasswordChange: _validatePasswords,
                    isPasswordVisible: _isPasswordVisible,
                    isConfirmPasswordVisible: _isConfirmPasswordVisible,
                    togglePasswordVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    toggleConfirmPasswordVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? _resetPassword : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF725E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 13.0),
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
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      _onBackPressed(); // Call the same onBackPressed method
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
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;

  const PasswordInputSection({
    Key? key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.errorText,
    required this.isButtonEnabled,
    required this.onPasswordChange,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.togglePasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/set_new_password.png',
          width: screenWidth * 0.5,
          height: screenHeight * 0.25,
          fit: BoxFit.fill,
        ),
        SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            labelText: "New Password",
            suffixIcon: IconButton(
              icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: togglePasswordVisibility,
            ),
          ),
          onChanged: (_) => onPasswordChange(),
        ),
        SizedBox(height: 10),
        TextField(
          controller: confirmPasswordController,
          obscureText: !isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            errorText: errorText,
            suffixIcon: IconButton(
              icon: Icon(isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: toggleConfirmPasswordVisibility,
            ),
          ),
          onChanged: (_) => onPasswordChange(),
        ),
      ],
    );
  }
}

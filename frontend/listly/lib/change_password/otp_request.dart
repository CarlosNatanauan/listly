import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './set_new_password.dart';
import '../dialogs/loading_dialog.dart';
import '../services/api_service.dart';
import '../screens/onboarding_screen.dart';

import '../screens/auth/login_screen.dart';

class OTPRequestScreen extends StatefulWidget {
  final String email;

  OTPRequestScreen({required this.email});

  @override
  _OTPRequestScreenState createState() => _OTPRequestScreenState();
}

class _OTPRequestScreenState extends State<OTPRequestScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    for (var controller in _otpControllers) {
      controller.addListener(_checkIfAllFilled);
    }
  }

  void _checkIfAllFilled() {
    setState(() {
      _isButtonEnabled = _otpControllers.every((controller) =>
          controller.text.isNotEmpty); // Check if all fields are filled
    });
  }

  Future<void> _submitOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    //print('OTP entered: $otp');

    // Show loading dialog
    showDialog(
      context: context,
      builder: (context) => LoadingDialog(message: "Verifying OTP"),
    );

    try {
      // Call the verifyOtp method from the API service
      final response = await ApiService.verifyOtp(widget.email, otp);

      // Dismiss the loading dialog
      Navigator.of(context).pop();

// Navigate to SetNewPasswordScreen upon successful verification
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              SetNewPasswordScreen(email: widget.email), // Pass email here
        ),
      );
    } catch (e) {
      // Dismiss the loading dialog
      Navigator.of(context).pop();

      if (e.toString().contains('Invalid OTP')) {
        // Show error dialog for invalid OTP
        _showErrorDialog("Invalid OTP", "The OTP you entered is incorrect.");
        _clearOTPFields();
      } else if (e.toString().contains('OTP expired')) {
        // Show error dialog for expired OTP
        _showExpiredDialog();
      } else {
        // Handle any other errors
        _showErrorDialog("Error", e.toString());
      }
    }
  }

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear(); // Clear the OTP input fields
    }
  }

  Future<void> _showExpiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("OTP Expired"),
        content: Text("The OTP is expired. Do you want to send it again?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true); // Close the dialog
              // Attempt to resend the OTP
              try {
                await ApiService.requestOtp(widget.email);

                // Before showing the SnackBar, ensure the widget is still mounted
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("OTP sent again!")),
                  );
                }
              } catch (e) {
                // Check for daily OTP request limit error
                if (e.toString().contains('daily OTP request limit')) {
                  if (mounted) {
                    _showDialog(
                      context,
                      'Request Limit Exceeded',
                      'You have reached the maximum number of OTP requests for today. Please try again tomorrow.',
                    );
                  }
                } else {
                  if (mounted) {
                    _showErrorDialog("Error", e.toString());
                  }
                }
              }
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (result != null && result) {
      // User chose to send OTP again
    }
  }

  Future<void> _showDialog(
      BuildContext context, String title, String content) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => OnboardingScreen()),
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
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    // Show the confirmation dialog when back button is pressed
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Leave OTP Session?"),
            content: Text(
                "Are you sure you want to leave this session? Your OTP might expire."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Dismiss
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm and pop dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => OnboardingScreen()),
                  ); // Go to OnboardingScreen
                },
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed
  }

  Future<bool> _backToLogin() async {
    // Show the confirmation dialog when back button is pressed
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Leave OTP Session?"),
            content: Text(
                "Are you sure you want to leave this session? Your OTP might expire."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Dismiss
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm and pop dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ); // Go to OnboardingScreen
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
    for (var controller in _otpControllers) {
      controller.dispose(); // Dispose the controllers
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onBackPressed, // Detect back button press
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus(); // Dismiss the keyboard when tapping outside
          },
          child: SingleChildScrollView(
            child: Center(
              // Center the content
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30), // Space at the top
                    // Encapsulated OTP input section
                    OTPInputSection(
                      email: widget.email,
                      otpControllers: _otpControllers,
                      onChange: _checkIfAllFilled,
                    ),
                    SizedBox(height: 20), // Space before Continue button
                    // Continue button
                    SizedBox(
                      width:
                          screenWidth * 0.8, // Set width based on screen width
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? _submitOTP : null,
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
                          'Continue',
                          style:
                              TextStyle(fontSize: 20), // Consistent text size
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Space before back to login
                    // Back to Login clickable text
                    TextButton(
                      onPressed: _backToLogin,
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
        ),
      ),
    );
  }
}

// Encapsulated OTP input section widget
class OTPInputSection extends StatelessWidget {
  final String email;
  final List<TextEditingController> otpControllers;
  final VoidCallback onChange;

  const OTPInputSection({
    Key? key,
    required this.email,
    required this.otpControllers,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align
      children: [
        // Image at the center
        Image.asset(
          'assets/images/otp_request.png', // Replace with your image asset
          width: screenWidth * 0.5, // Responsive width
          height: screenHeight * 0.25, // Responsive height
          fit: BoxFit.fitWidth,
        ),
        // Email confirmation text
        Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align
          children: [
            Text(
              'We sent you a code to',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 5),
            Text(
              email, // Display the user's email
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 30), // Space before OTP input
        // OTP input fields
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Evenly space out the fields
          children: List.generate(otpControllers.length, (index) {
            return Container(
              width: screenWidth * 0.12, // Responsive width for each input
              child: TextField(
                controller: otpControllers[index],
                cursorColor: Color(0xFFFF725E),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center, // Center the text
                maxLength: 1, // Limit to one character
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  counterText: '', // Hide the counter text
                ),
                onChanged: (value) {
                  onChange(); // Call the onChange callback
                  if (value.length == 1 && index < otpControllers.length - 1) {
                    // Move to the next input if current is filled
                    FocusScope.of(context).nextFocus();
                  } else if (value.isEmpty && index > 0) {
                    // Move to the previous input if current is emptied
                    FocusScope.of(context).previousFocus();
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

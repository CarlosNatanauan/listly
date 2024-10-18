import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './set_new_password.dart';

class OTPRequestScreen extends StatefulWidget {
  final String email;

  OTPRequestScreen({required this.email}); // Constructor to accept email

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

  void _submitOTP() {
    final otp = _otpControllers.map((controller) => controller.text).join();
    print('OTP entered: $otp'); // For debugging

    // Navigate to SetNewPasswordScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SetNewPasswordScreen(),
      ),
    );
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

    return Scaffold(
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
                    width: screenWidth * 0.8, // Set width based on screen width
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? _submitOTP
                          : null, // Enable only if all fields are filled
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
                        style: TextStyle(fontSize: 20), // Consistent text size
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Space before resend email text
                  // Resend Email clickable text
                  TextButton(
                    onPressed: () {
                      print("Didn't receive the email? Click here");
                      // Add logic to resend the email
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Didn't receive the email?",
                            style: TextStyle(
                              color: Colors.black54, // Set the color to black
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: " Click here",
                            style: TextStyle(
                              color: Color(0xFFFF725E),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Space before back to login
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center, // Center text
            ),
            Text(
              email, // Email displayed on the next line
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center, // Center text
            ),
          ],
        ),
        SizedBox(height: 20), // Space before OTP input
        // OTP input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: screenWidth * 0.13, // Adjust width as needed
              child: TextField(
                controller: otpControllers[index],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFFFF725E)),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                onChanged: (value) {
                  if (value.length > 1) {
                    // Remove the extra character(s)
                    otpControllers[index].text = value.substring(0, 1);
                  }
                  if (value.length == 1 && index < 5) {
                    FocusScope.of(context).nextFocus(); // Move to next field
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context)
                        .previousFocus(); // Move to previous field
                  }
                  onChange(); // Check if all fields are filled
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

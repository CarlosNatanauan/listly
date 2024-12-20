import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'set_new_password.dart';
import '../../../../dialogs/loading_dialog.dart';
import '../../../../services/api_service.dart';
import '../../account_screen.dart';
import '../../../../providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OTPRequestScreenInside extends ConsumerStatefulWidget {
  final String email;

  OTPRequestScreenInside({required this.email});

  @override
  _OTPRequestScreenState createState() => _OTPRequestScreenState();
}

class _OTPRequestScreenState extends ConsumerState<OTPRequestScreenInside> {
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
    print('OTP entered: $otp');

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
          builder: (context) => SetNewPasswordScreenInside(email: widget.email),
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
      controller.clear();
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
              Navigator.of(context).pop(true);
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
                        ref);
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
      BuildContext context, String title, String content, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final token = await authService.getToken();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog

              if (user != null && token != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AccountScreen(
                      username: user.username, // Pass the username
                      email: user.email, // Pass the email
                      token: token, // Pass the token
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No user is logged in')),
                );
              }
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

  Future<bool> _onBackPressed(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final token = await authService.getToken();

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Leave OTP Session?"),
            content: Text(
                "Are you sure you want to leave this session? Your OTP might expire."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  final shouldLeave = await _onBackPressed(context, ref);
                  if (shouldLeave) {
                    if (user != null && token != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(
                            username: user.username,
                            email: user.email,
                            token: token,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No user is logged in')),
                      );
                    }
                  }
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
      onWillPop: () => _onBackPressed(context, ref),
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),

                    OTPInputSection(
                      email: widget.email,
                      otpControllers: _otpControllers,
                      onChange: _checkIfAllFilled,
                    ),
                    SizedBox(height: 20),
                    // Continue button
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? _submitOTP : null,
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
                          'Continue',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        final shouldLeave = await _onBackPressed(context, ref);
                        if (shouldLeave) {
                          final authService = ref.read(authServiceProvider);
                          final user = authService.currentUser;
                          final token = await authService.getToken();

                          if (user != null && token != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => AccountScreen(
                                  username: user.username,
                                  email: user.email,
                                  token: token,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No user is logged in')),
                            );
                          }
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
                    )
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image at the center
        Image.asset(
          'assets/images/otp_request.png',
          width: screenWidth * 0.5,
          height: screenHeight * 0.25,
          fit: BoxFit.fitWidth,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'We sent you a code to',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 5),
            Text(
              email,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 30),
        // OTP input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(otpControllers.length, (index) {
            return Container(
              width: screenWidth * 0.12,
              child: TextField(
                controller: otpControllers[index],
                cursorColor: Color(0xFFFF725E),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  counterText: '',
                ),
                onChanged: (value) {
                  onChange();
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

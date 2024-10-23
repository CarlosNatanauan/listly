import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the splash screen

class SessionExpiredScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false, // Disable back button functionality
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the image in the middle
              Image.asset(
                'assets/images/error_400.png', // Ensure this asset exists
                width: screenWidth * 0.6, // Set responsive width
                height: screenHeight * 0.3, // Set responsive height
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30), // Space between image and text

              // Explanation text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Your session has expired due to modifications made to your account. Please log in again to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 30), // Space between text and button

              // Button to redirect to Splash screen
              SizedBox(
                width: screenWidth * 0.8, // Responsive button width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF725E), // Custom button color
                    foregroundColor: Colors.white, // Button text color
                    padding: EdgeInsets.symmetric(vertical: 13.0), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded edges
                    ),
                    elevation: 5, // Button shadow
                  ),
                  child: Text(
                    'Log in',
                    style: TextStyle(fontSize: 20), // Button text size
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import './auth/login_screen.dart';
import './auth/register_screen.dart'; // Ensure the correct import for RegisterScreen

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 50.0), // Added padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image with space on top
              SizedBox(height: 30), // Space on top of the image
              Image.asset(
                'assets/images/add_notes_image.png', // Replace with your image asset
                width: screenWidth * 0.6, // Responsive width
                height: screenHeight * 0.32, // Responsive height
                fit: BoxFit.cover,
              ),
              SizedBox(height: 30), // Space between image and text
              // Big Hello
              Text(
                'Hello!',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              SizedBox(height: 10), // Space between texts
              // Welcome message
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome to ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextSpan(
                      text: 'Listly',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // Make 'Listly' bold
                        color: Colors.grey[600],
                      ),
                    ),
                    TextSpan(
                      text: '! Your simple note-taking and to-do list app.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40), // Space before buttons
              // Login button
              SizedBox(
                width: screenWidth * 0.8, // Set width based on screen width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF725E), // Custom color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(
                        vertical: 13.0), // Vertical padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded edges
                    ),
                    elevation: 5, // Shadow effect
                  ),
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10), // Space between login button and OR
              // OR text
              Text(
                '- OR -',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10), // Space between OR and signup button
              // Register button
              SizedBox(
                width: screenWidth * 0.8, // Set width based on screen width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF725E), // Custom color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(
                        vertical: 13.0), // Vertical padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded edges
                    ),
                    elevation: 5, // Shadow effect
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                    ),
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

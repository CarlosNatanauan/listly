import 'package:flutter/material.dart';
import 'account_screen/change_password_loggedin/forgot_password.dart';
import 'account_screen/account_deletion.dart';

class AccountScreen extends StatelessWidget {
  final String username;
  final String email;

  final String token;

  AccountScreen(
      {required this.username, required this.email, required this.token});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF725E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to MainPage
          },
        ),
        title: Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Section
            Text(
              'Username',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                username, // Display logged-in username
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Email Section
            Text(
              'Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                email, // Display logged-in email
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Change Password Button
            Text(
              'Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: screenWidth * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to ForgotPasswordScreenInside with email passed as a parameter
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ForgotPasswordScreenInside(email: email),
                    ),
                  );
                },
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
                  'Change Password',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 30),
            // Account Deletion Section
            Text(
              'Account Deletion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: screenWidth * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AccountDeletion(
                        email: email,
                        token: token,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF725E), // Red color for delete
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(
                    vertical: 13.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded edges
                  ),
                  elevation: 5, // Shadow effect
                ),
                child: Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

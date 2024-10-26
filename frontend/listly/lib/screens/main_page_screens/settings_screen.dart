import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './settings_screens/clear_data.dart';

class SettingsScreen extends ConsumerWidget {
  final String email;
  final String token;

  // Update the constructor to accept email and token
  SettingsScreen({required this.email, required this.token}) {
    print("SettingsScreen initialized with email: $email, token: $token");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Settings',
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
            Material(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: () {
                  // Pass email and token to ClearDataScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ClearDataScreen(
                        email: email,
                        token: token,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: screenWidth,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Clear Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Material(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: () {
                  // Add logic to view privacy policy and terms of service
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: screenWidth,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Material(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: () {
                  // Add logic to view privacy policy and terms of service
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: screenWidth,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Privacy Policy and Terms of Service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrivacyPolicyTermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF725E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Privacy Policy & Terms',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Your privacy matters to us. This Privacy Policy outlines how we handle your data, including personal details, notes, and tasks stored in the app.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 20),
            Text(
              "1. Information Collection",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "We collect information, such as your name, email, and content within your notes and tasks. This data enables us to offer personalized services and improve functionality.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Text(
              "2. Data Storage and Security",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "All notes and tasks are stored securely. We implement strict access control and encryption protocols to protect your data from unauthorized access.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Text(
              "3. Account Security",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "We encourage you to use a strong password and to change it periodically. Our system is designed to protect your account, but account security is a shared responsibility.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 20),
            Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "These terms govern your use of the notepad app. By creating an account and using the app, you agree to abide by these terms.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Text(
              "1. User Responsibilities",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "You are responsible for the content you store in your notes and tasks. Please avoid uploading sensitive information, as we are not liable for any unauthorized access.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Text(
              "2. Content Guidelines",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "While this app provides a private notepad, any content that violates our policies may result in account suspension. Examples include hate speech, illegal activities, or harmful content.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Text(
              "3. Limitation of Liability",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "We are not responsible for any losses or damages that arise from the use of our app. By using our service, you acknowledge and accept this limitation of liability.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Text(
              "4. Changes to Terms",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "We may update our Privacy Policy & Terms periodically. We will notify you of any major changes via email or app notifications.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 30),
            Text(
              "For any questions, please contact our support team at listly.auth@gmail.com.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

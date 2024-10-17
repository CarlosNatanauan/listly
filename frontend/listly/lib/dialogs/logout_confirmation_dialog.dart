// logout_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart'; // Import for logout
import '../providers/socket_service_provider.dart'; // Import socket service
import '../screens/onboarding_screen.dart';

Future<void> showLogoutConfirmationDialog(
    BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // User can dismiss the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Confirm Logout'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to logout?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Logout', style: TextStyle(color: Color(0xFFFF725E))),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              ref
                  .read(authServiceProvider)
                  .logout(); // Call the logout function
              ref
                  .read(socketServiceProvider)
                  .disconnect(); // Disconnect the socket
              // Directly navigate to OnboardingScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OnboardingScreen(),
                ),
              ); // Redirect to OnboardingScreen
            },
          ),
        ],
      );
    },
  );
}

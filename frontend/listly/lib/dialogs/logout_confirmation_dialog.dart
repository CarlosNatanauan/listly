// logout_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart'; // Import for logout
import '../providers/socket_service_provider.dart'; // Import socket service

import '../providers/socket_service_tasks_provider.dart'; // Import socket service
import '../screens/splash_screen.dart';

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

              // Logout only affects this device's socket
              ref
                  .read(authServiceProvider)
                  .logout(); // Call the logout function

              // Disconnect the sockets for the current device only
              ref.read(socketServiceProvider).disconnect();
              ref.read(socketServiceTasksProvider).disconnect();

              // Navigate to the SplashScreen after logging out
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SplashScreen(),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

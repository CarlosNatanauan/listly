import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../screens/main_page.dart';
import 'dart:async';

class NoInternetScreen extends StatefulWidget {
  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _listenToConnectivityChanges();
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        // Check for connectivity in the list of results
        if (results.isNotEmpty && results.first != ConnectivityResult.none) {
          _navigateToMainPage();
        }
      },
    );
  }

  void _navigateToMainPage() {
    _connectivitySubscription
        .cancel(); // Stop listening after connection is restored
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MainPage(userName: "User"), // Pass actual username if available
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Please check your connection.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

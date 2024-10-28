import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'providers/connectivity_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  ConnectivityWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityProvider);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          if (connectivityStatus.value == ConnectivityResult.none)
            NoInternetScreenOverlay(), // Display overlay when no internet
        ],
      ),
    );
  }
}

// Overlay for no internet screen
class NoInternetScreenOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            width: screenWidth * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/no_connection.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Please check your connection and try again.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                LoadingAnimationWidget.inkDrop(
                  color: Color(0xFFFF725E),
                  size: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

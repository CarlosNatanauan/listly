import 'package:flutter/material.dart';

// Custom Page Route for right-to-left transition
class SlideFromRightPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideFromRightPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // End at the current position (no offset)
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          opaque: false, // Ensures the background is still visible
        );
}

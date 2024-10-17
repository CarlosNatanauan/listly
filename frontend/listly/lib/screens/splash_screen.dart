import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_page.dart';
import '../providers/auth_providers.dart'; // Import the providers
import './onboarding_screen.dart';

class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _checkLoginStatus(ref, context);
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _checkLoginStatus(WidgetRef ref, BuildContext context) async {
    final authService = ref.read(authServiceProvider);
    await authService.loadUserFromPrefs(); // Load user from prefs
    final token = await authService.getToken(); // Call the new method

    if (token != null) {
      // Set the current user in the userProvider if token is found
      ref.read(userProvider.notifier).state = authService.currentUser;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainPage(
            userName: '${authService.currentUser?.username}',
          ),
        ),
      );
    } else {
      // Navigate to OnboardingScreen if no token found
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }
}

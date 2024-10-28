import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fetching_screen.dart';
import '../providers/auth_providers.dart';
import './onboarding_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../no_internet_screen.dart';

class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _checkConnectivityAndLoginStatus(ref, context);
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Color(0xFFFF725E),
          size: 50,
        ),
      ),
    );
  }

  Future<void> _checkConnectivityAndLoginStatus(
      WidgetRef ref, BuildContext context) async {
    final connectivityStatus = await Connectivity().checkConnectivity();

    if (connectivityStatus != ConnectivityResult.none) {
      _checkLoginStatus(ref, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NoInternetScreen()),
      );
    }
  }

  Future<void> _checkLoginStatus(WidgetRef ref, BuildContext context) async {
    final authService = ref.read(authServiceProvider);
    await authService.loadUserFromPrefs();
    final token = await authService.getToken();

    if (token != null) {
      ref.read(userProvider.notifier).state = authService.currentUser;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => FetchingScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }
}

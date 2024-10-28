import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'main_page.dart';
import '../providers/auth_providers.dart';
import '../providers/socket_service_provider.dart';
import 'onboarding_screen.dart';
import '../no_internet_screen.dart';
import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FetchingScreen extends ConsumerStatefulWidget {
  @override
  _FetchingScreenState createState() => _FetchingScreenState();
}

class _FetchingScreenState extends ConsumerState<FetchingScreen> {
  String? _token;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    final authService = ref.read(authServiceProvider);
    final connectivityStatus = await Connectivity().checkConnectivity();

    if (connectivityStatus != ConnectivityResult.none) {
      _token = await authService.getToken();
      if (_token != null) {
        _connectSocketAndNavigate();
      } else {
        _navigateToOnboarding();
      }
    } else {
      _monitorConnectivity();
      _navigateToNoInternetScreen();
    }
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none)) {
          _connectivitySubscription?.cancel();
          _connectSocketAndNavigate();
        }
      },
    );
  }

  Future<void> _connectSocketAndNavigate() async {
    if (_token != null) {
      ref
          .read(socketServiceProvider)
          .connect(_token!, ref.read(noteUpdateProvider));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
              userName:
                  ref.read(authServiceProvider).currentUser?.username ?? ''),
        ),
      );
    }
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
    );
  }

  void _navigateToNoInternetScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NoInternetScreen()),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Color(0xFFFF725E),
          size: 50,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listly/screens/onboarding_screen.dart';
import 'main_page.dart'; // Assuming this is where your MainPage class is defined
import '../providers/auth_providers.dart'; // Assuming this is your authentication provider
import '../providers/notes_provider.dart'; // Assuming this is your notes provider
import '../providers/socket_service_provider.dart';

class FetchingScreen extends ConsumerStatefulWidget {
  @override
  _FetchingScreenState createState() => _FetchingScreenState();
}

class _FetchingScreenState extends ConsumerState<FetchingScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authService = ref.read(authServiceProvider);
    String? token = await authService.getToken();

    if (token != null) {
      _token = token;

      // Reconnect to the socket services
      final socketService = ref.read(socketServiceProvider);
      socketService.connect(_token!, ref.read(noteUpdateProvider));

      // Fetch notes before navigating to MainPage
      await _fetchNotes();

      // Navigate to MainPage after data is fetched, using 'username' from User model
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainPage(userName: authService.currentUser?.username ?? ''),
        ),
      );
    } else {
      // If no token is found, go back to OnboardingScreen (login screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(),
        ),
      );
    }
  }

  Future<void> _fetchNotes() async {
    if (_token != null) {
      try {
        await ref.read(notesProvider(_token!).notifier).fetchNotes();
      } catch (error) {
        print("Error fetching notes: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching notes")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Show a loading indicator while fetching
      ),
    );
  }
}

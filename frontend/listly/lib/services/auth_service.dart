import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Function to load user from SharedPreferences
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final username = prefs.getString('username'); // Retrieve username

    if (token != null && username != null) {
      _currentUser = User(id: 'user_id_here', username: username, token: token);
    } else {
      print('No user found in shared preferences.');
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      final data = await ApiService.login(username, password);

      // Check that the response data is valid and contains required fields
      if (data != null && data['token'] != null && data['userId'] != null) {
        final user =
            User.fromJson(data); // Create User object from the response
        _currentUser = user; // Set the current user
        await _storeToken(user.token); // Store token securely
        await _storeUsername(user.username); // Store username
        return user;
      } else {
        print('Login response does not contain expected data.'); // Log error
        return null;
      }
    } catch (e) {
      print('Login error: $e'); // Log the error for debugging
      return null;
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _storeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username); // Store username securely
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username'); // Remove username
    _currentUser = null;
  }
}

// Define a provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Define a StateProvider to manage the current user
final userProvider = StateProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

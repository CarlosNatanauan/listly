//auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../providers/socket_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final username = prefs.getString('username');
    final email = prefs.getString('email');

    if (token != null && username != null && email != null) {
      _currentUser = User(
          id: 'user_id_here', username: username, token: token, email: email);
    }
  }

  Future<User?> login(String username, String password, WidgetRef ref) async {
    try {
      final data = await ApiService.login(username, password);

      // Ensure that the response contains all necessary fields
      if (data != null &&
          data['token'] != null &&
          data['userId'] != null &&
          data['email'] != null) {
        final user = User.fromJson(data);
        _currentUser = user;
        await _storeToken(user.token);
        await _storeUsername(user.username);
        await _storeEmail(user.email);

        // Reconnect to socket services
        final socketService = ref.read(socketServiceProvider);
        socketService.connect(user.token, ref.read(noteUpdateProvider));

        return user;
      } else {
        // Handle cases where email, token, or userId is missing
        print("Login error: Missing fields in the API response");
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

// Add method to store email in SharedPreferences
  Future<void> _storeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final data = await ApiService.register(username, email, password);
      return true;
    } catch (e) {
      if (e.toString().contains('duplicate key error')) {
        if (e.toString().contains('email')) {
          throw Exception(
              'Email already exists. Please use a different email.');
        } else if (e.toString().contains('username')) {
          throw Exception(
              'Username already exists. Please choose another one.');
        }
      }
      throw Exception('Registration failed. Please try again.');
    }
  }

  Future<bool> isTokenValid(String token) async {
    try {
      // Fetch passwordChangedAt timestamp
      final passwordData = await ApiService.getPasswordChangedAt(token);
      DateTime? passwordChangedAtServer;
      if (passwordData != null && passwordData['passwordChangedAt'] != null) {
        passwordChangedAtServer =
            DateTime.parse(passwordData['passwordChangedAt']);
      }

      // Fetch accountDeletedAt timestamp
      final deleteData = await ApiService.getAccountDeletedAt(token);
      DateTime? accountDeletedAtServer;
      if (deleteData != null && deleteData['accountDeletedAt'] != null) {
        accountDeletedAtServer = DateTime.parse(deleteData['accountDeletedAt']);
      }

      // Decode the token to get the issued-at (iat) time
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final tokenIssuedAt = decodedToken['iat'];
      final tokenIssuedAtDateTime =
          DateTime.fromMillisecondsSinceEpoch(tokenIssuedAt * 1000);

      // If token was issued before either the password was changed or the account was deleted, return false
      if ((accountDeletedAtServer != null &&
              tokenIssuedAtDateTime.isBefore(accountDeletedAtServer)) ||
          (passwordChangedAtServer != null &&
              tokenIssuedAtDateTime.isBefore(passwordChangedAtServer))) {
        return false;
      }

      // If no issues, the token is still valid
      return true;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _storeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
    _currentUser = null;
  }
}

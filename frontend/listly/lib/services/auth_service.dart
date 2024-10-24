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

    if (token != null && username != null) {
      _currentUser = User(id: 'user_id_here', username: username, token: token);
    }
  }

  Future<User?> login(String username, String password, WidgetRef ref) async {
    try {
      final data = await ApiService.login(username, password);
      if (data != null && data['token'] != null && data['userId'] != null) {
        final user = User.fromJson(data);
        _currentUser = user;
        await _storeToken(user.token);
        await _storeUsername(user.username);

        // Reconnect to the socket services with the new token after login
        final socketService = ref.read(socketServiceProvider);
        socketService.connect(user.token, ref.read(noteUpdateProvider));

        return user;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
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
      final data = await ApiService.getPasswordChangedAt(token);
      if (data == null || data['passwordChangedAt'] == null) {
        // If passwordChangedAt is null, assume token is valid (password hasn't been changed)
        return true;
      }

      final passwordChangedAtServer = DateTime.parse(data['passwordChangedAt']);

      // Decode the token to extract all claims
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Extract the issued-at (iat) time from the token
      final tokenIssuedAt = decodedToken['iat'];

      // Convert the issued-at time to DateTime
      final tokenIssuedAtDateTime =
          DateTime.fromMillisecondsSinceEpoch(tokenIssuedAt * 1000);

      // If token was issued before the password was changed, return false
      return tokenIssuedAtDateTime.isAfter(passwordChangedAtServer);
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

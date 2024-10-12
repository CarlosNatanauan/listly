//providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart'; // Adjust the path based on your folder structure
import '../models/user.dart'; // Adjust the path based on your folder structure

// Provide a singleton instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StateProvider for the current logged-in user
final userProvider = StateProvider<User?>((ref) => null);

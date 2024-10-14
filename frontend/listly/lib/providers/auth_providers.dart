import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/todo.dart';

// Provide a singleton instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StateProvider for the current logged-in user
final userProvider = StateProvider<User?>((ref) => null);

// auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

// Provide a singleton instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StateProvider for the current logged-in user
final userProvider = StateProvider<User?>((ref) => null);

// Add logout function in providers
void logout(WidgetRef ref) {
  ref
      .read(authServiceProvider)
      .logout(); // Call the logout function from AuthService
  ref.read(userProvider.notifier).state = null; // Clear the user state
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_providers.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final socketService = SocketService();
  return socketService;
});

// Callback to handle note updates via socket events
final noteUpdateProvider = Provider<void Function(Note)>((ref) {
  return (updatedNote) {
    final token = ref.watch(authServiceProvider).currentUser?.token;
    if (token != null) {
      ref
          .read(notesProvider(token).notifier)
          .fetchNotes(); // Pass the token when accessing .notifier
    }
  };
});

//notes_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/socket_service_notes.dart';
import '../models/note.dart';
import '../providers/socket_service_provider.dart';

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final String token;
  final SocketService socketService; // Add socket service

  NotesNotifier(this.token, this.socketService) : super(AsyncLoading()) {
    // Load notes when the notifier is created
    fetchNotes();

    // Connect to the Notes socket service for real-time updates
    socketService.connect(token, _handleNoteUpdate);
  }

  // Handle real-time note updates from the socket
  void _handleNoteUpdate(Note updatedNote) async {
    // Fetch notes or handle specific update logic if required
    await fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      final notes = await ApiService.fetchNotes(token);
      state = AsyncData(notes); // Update the state with fetched notes
    } catch (error) {
      state = AsyncError(error, StackTrace.current); // Provide a stack trace
    }
  }

  Future<Note> addOrUpdateNote(Note note) async {
    try {
      Note savedNote;
      if (note.id.isEmpty) {
        // Adding a new note
        savedNote = await ApiService.saveNote(note, token);
      } else {
        // Updating an existing note
        savedNote = await ApiService.updateNote(note, token);
      }
      await fetchNotes(); // Refetch notes after saving
      return savedNote; // Return the saved or updated note
    } catch (error) {
      state = AsyncError(error, StackTrace.current); // Provide a stack trace
      rethrow; // Re-throw the error to be caught higher up if needed
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await ApiService.deleteNote(noteId, token);
      await fetchNotes(); // Refetch notes after deletion
    } catch (error) {
      state = AsyncError(error, StackTrace.current); // Provide a stack trace
    }
  }
}

// Create a provider for the NotesNotifier
final notesProvider =
    StateNotifierProvider.family<NotesNotifier, AsyncValue<List<Note>>, String>(
  (ref, token) {
    final socketService =
        ref.watch(socketServiceProvider); // Get the socket service
    return NotesNotifier(
        token, socketService); // Pass the socket service to NotesNotifier
  },
);

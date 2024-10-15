import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/note.dart';

// Define a StateNotifier to manage the notes state
class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final String token;

  NotesNotifier(this.token) : super(AsyncLoading()) {
    fetchNotes(); // Load notes when the notifier is created
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
  return NotesNotifier(token);
});

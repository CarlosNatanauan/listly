import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/note.dart';

// Define a StateNotifier to manage the notes state
class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final String token;

  NotesNotifier(this.token) : super(AsyncLoading()) {
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      final notes = await ApiService.fetchNotes(token);
      state = AsyncData(notes);
    } catch (error) {
      state = AsyncError(error, StackTrace.current); // Provide a stack trace
    }
  }

  Future<void> addOrUpdateNote(Note note) async {
    try {
      if (note.id.isEmpty) {
        // Adding a new note
        await ApiService.saveNote(note, token);
      } else {
        // Updating an existing note
        await ApiService.updateNote(note, token);
      }
      await fetchNotes(); // Refetch notes after saving
    } catch (error) {
      state = AsyncError(error, StackTrace.current); // Provide a stack trace
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

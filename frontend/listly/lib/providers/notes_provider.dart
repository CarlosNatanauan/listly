import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/note.dart';

final notesProvider =
    FutureProvider.family<List<Note>, String>((ref, token) async {
  return await ApiService.fetchNotes(token);
});

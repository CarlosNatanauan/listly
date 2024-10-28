//socket_service_notes.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/note.dart';

class SocketService {
  IO.Socket? socket;

  // Connect method to accept a callback
  void connect(String token, Function(Note) onNoteUpdate) {
    disconnect(); // Ensure any previous connection is closed before reconnecting

    socket = IO.io('https://listly-ocau.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    socket!.on('connect', (_) {
      print('Connected to socket server');
    });

    socket!.on('noteUpdated', (data) {
      Note updatedNote = Note.fromJson(data);
      onNoteUpdate(updatedNote);
    });

    socket!.on('disconnect', (_) {
      print('Disconnected from socket server');
    });
  }

  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
      socket = null;
    }
  }

  void onNoteUpdate(String noteId, Function(Note) callback) {
    socket!.on('noteUpdated_$noteId', (data) {
      Note updatedNote = Note.fromJson(data);
      callback(updatedNote);
    });
  }

  void emitNoteUpdate(Map<String, dynamic> note) {
    String noteId = note['_id'] ?? '';
    socket!.emit('noteUpdated_$noteId', note);
  }
}

//socket_service_notes.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/note.dart';

class SocketService {
  late IO.Socket socket;

  // Connect method to accept a callback
  void connect(String token, Function(Note) onNoteUpdate) {
    socket = IO.io('http://192.168.0.111:5000', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    socket.on('connect', (_) {
      print('Connected to socket server');
    });

    socket.on('noteUpdated', (data) {
      Note updatedNote = Note.fromJson(data);
      onNoteUpdate(updatedNote); // Pass updated note to the callback
    });

    socket.on('disconnect', (_) {
      print('Disconnected from socket server');
    });
  }

  void onNoteUpdate(String noteId, Function(Note) callback) {
    socket.on('noteUpdated_$noteId', (data) {
      Note updatedNote = Note.fromJson(data);
      callback(updatedNote);
    });
  }

  void emitNoteUpdate(Map<String, dynamic> note) {
    String noteId = note['_id'] ?? ''; // Ensure '_id' exists in the note data
    socket.emit('noteUpdated_$noteId', note);
  }

  void disconnect() {
    socket.disconnect();
  }
}

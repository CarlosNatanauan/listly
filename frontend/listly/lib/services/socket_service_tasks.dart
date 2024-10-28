//socket service tasks
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketServiceTasks {
  late IO.Socket socket;

  void connect(String token, Function(Map<String, dynamic>) onTaskUpdate) {
    print('Connecting to socket with token: $token'); // Debug statement
    socket = IO.io('https://listly-ocau.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    socket.on('connect', (_) {
      print('Connected to socket server'); // Debug statement
    });

    // Listen for task updates (general 'taskUpdated' event)
    socket.on('taskUpdated', (data) {
      print('Task update received from server: $data'); // Debug statement
      onTaskUpdate(data);
    });

    socket.on('disconnect', (_) {
      print('Disconnected from socket server'); // Debug statement
    });
  }

  // Emit task updates (Add, Update, Delete) using a general 'taskUpdated' event
  void emitTaskUpdate(Map<String, dynamic> task) {
    print('Emitting task update: $task'); // Debug statement
    socket.emit('taskUpdated', task);
  }

  void disconnect() {
    print('Disconnecting from socket'); // Debug statement
    socket.disconnect();
  }
}

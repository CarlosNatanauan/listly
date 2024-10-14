import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/todo.dart'; // Import your ToDo model
import '../models/note.dart'; // Import your ToDo model

class ApiService {
  static const String _baseUrl = 'http://192.168.0.111:5000'; // Backend API URL

  static Future<dynamic> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log in');
    }
  }

  static Future<dynamic> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['message']);
    } else {
      throw Exception('Failed to register');
    }
  }

  static Future<List<dynamic>> fetchTasks(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tasks'), // Adjust to your backend URL
      headers: {
        'Authorization': 'Bearer $token', // Include token for authentication
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse; // Return the raw JSON response
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<void> updateTask(ToDo task, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tasks/${task.id}'), // Include task ID in the URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include authorization token
      },
      body: jsonEncode({
        'task': task.task, // Send updated task text
        'completed': task.completed, // Send completion status
      }),
    );

    print('Update response status: ${response.statusCode}'); // Log status
    print('Update response body: ${response.body}'); // Log body

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  static Future<String> addTask(String task, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'task': task,
        'completed': false,
      }),
    );

    if (response.statusCode == 201) {
      return response.body; // Return the raw JSON body as a string
    } else {
      throw Exception('Failed to add task');
    }
  }

  static Future<void> deleteTask(String taskId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tasks/$taskId'),
      headers: {
        'Authorization': 'Bearer $token', // Include token for authentication
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

  //Notes
  static Future<List<Note>> fetchNotes(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/notes'), // Adjust to your backend URL
      headers: {
        'Authorization': 'Bearer $token', // Include token for authentication
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((note) => Note.fromJson(note)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  //Saving notes
  static Future<Note> saveNote(Note note, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/notes'), // Adjust to your backend URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include authorization token
      },
      body: jsonEncode({
        'title': note.title,
        'content': note.content,
      }),
    );

    if (response.statusCode == 201) {
      return Note.fromJson(
          jsonDecode(response.body)); // Convert the saved note to Note object
    } else {
      throw Exception('Failed to save note');
    }
  }

  static Future<void> updateNote(Note note, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/notes/${note.id}'), // Use note ID in the URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include authorization token
      },
      body: jsonEncode({
        'title': note.title,
        'content': note.content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update note');
    }
  }

  static Future<void> deleteNote(String noteId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/notes/$noteId'), // Adjust to your backend URL
      headers: {
        'Authorization': 'Bearer $token', // Include token for authentication
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
  }
}

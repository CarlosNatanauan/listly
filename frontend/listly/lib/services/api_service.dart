//api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/todo.dart';
import '../models/note.dart';

class ApiService {
  static const String _baseUrl = 'https://listly-ocau.onrender.com';

  // New method to get the passwordChangedAt timestamp
  static Future<dynamic> getPasswordChangedAt(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/password-changed-at'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch passwordChangedAt');
    }
  }

  // New method to get the accountDeletedAt timestamp
  static Future<dynamic> getAccountDeletedAt(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/account-deleted-at'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch accountDeletedAt');
    }
  }

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
      Uri.parse('$_baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.isNotEmpty
          ? jsonResponse
          : []; // Ensure it’s not null
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

    print('Update response status: ${response.statusCode}');
    print('Update response body: ${response.body}');

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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

// Notes fetching with detailed error logging
  static Future<List<Note>> fetchNotes(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/notes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.isNotEmpty
          ? jsonResponse.map((note) => Note.fromJson(note)).toList()
          : []; // Ensure it’s not null
    } else {
      throw Exception('Failed to load notes');
    }
  }

  //Saving notes
  static Future<Note> saveNote(Note note, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/notes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': note.title,
        'content': note.content,
      }),
    );

    if (response.statusCode == 201) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save note');
    }
  }

  static Future<Note> updateNote(Note note, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/notes/${note.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': note.title,
        'content': note.content,
      }),
    );

    if (response.statusCode == 200) {
      // Return the updated Note object
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update note');
    }
  }

  static Future<void> deleteNote(String noteId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/notes/$noteId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
  }

  //changing password

  // Method to request OTP
  static Future<dynamic> requestOtp(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/request-reset'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle errors based on the response
      final error = jsonDecode(response.body);
      throw Exception(error['message']);
    }
  }

  // Method to verify OTP
  static Future<dynamic> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/verify-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle errors based on the response
      final error = jsonDecode(response.body);
      throw Exception(error['message']);
    }
  }

  static Future<void> changePassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  static Future<void> deleteAccount(String email, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/auth/delete-account'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete account');
    }
  }

  //for feedback

  static Future<void> submitFeedback(
      int rating, String additionalComments, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/feedback/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
        'additionalComments': additionalComments,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit feedback');
    }
  }
}

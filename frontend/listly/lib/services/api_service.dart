import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/todo.dart'; // Import your ToDo model

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
      Uri.parse('$_baseUrl/tasks/${task.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include authorization token
      },
      body: jsonEncode({
        'completed': task.completed,
      }),
    );

    print('Update response status: ${response.statusCode}'); // Log status
    print('Update response body: ${response.body}'); // Log body

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.body}');
    }
  }
}

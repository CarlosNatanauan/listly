import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl =
      'http://192.168.0.111:5000'; // Ensure this is correct

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
      // Log the error response for debugging
      print('Login failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to log in');
    }
  }

  static Future<dynamic> getUserData(String token) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/auth/user'), // Update this endpoint according to your API
      headers: {
        "Authorization":
            "Bearer $token", // Include the token in the Authorization header
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Log the error response for debugging
      print('Failed to fetch user data with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to fetch user data');
    }
  }
}

class User {
  final String id; // userId from the API response
  final String token; // JWT token
  final String username; // Username from the API response

  User({
    required this.id,
    required this.token,
    required this.username, // Add username as a required field
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'], // Use userId from the response
      token: json['token'], // Use token from the response
      username: json['username'], // Use username from the response
    );
  }
}

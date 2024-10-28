class User {
  final String id; // userId from the API response
  final String token; // JWT token
  final String username; // Username from the API response
  final String email; // Email from the API response

  User({
    required this.id,
    required this.token,
    required this.username,
    required this.email, 
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'], 
      token: json['token'], 
      username: json['username'], 
      email: json['email'], 
    );
  }
}

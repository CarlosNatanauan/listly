class User {
  final String id; // userId from the API response
  final String token; // JWT token

  User({
    required this.id,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'], // Use userId from the response
      token: json['token'], // Use token from the response
    );
  }
}

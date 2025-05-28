class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int streakCount;
  // Add other relevant fields as needed

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.streakCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      streakCount: json['streakCount'] as int? ?? 0, // Default to 0 if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'streakCount': streakCount,
    };
  }
}

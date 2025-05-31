// Enum for User Roles
enum UserRole {
  user,
  trainer,
  nutritionist,
  unknown, // For default or error cases
}

// Helper to convert string to UserRole
UserRole _userRoleFromString(String? roleString) {
  if (roleString == null) return UserRole.unknown;
  switch (roleString.toLowerCase()) {
    case 'user':
      return UserRole.user;
    case 'trainer':
      return UserRole.trainer;
    case 'nutritionist':
      return UserRole.nutritionist;
    default:
      return UserRole.unknown;
  }
}

// Helper to convert UserRole to string
String _userRoleToString(UserRole role) {
  return role.toString().split('.').last;
}

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int streakCount;
  final UserRole role;

  final String preferredWeightUnit;
  final String preferredDistanceUnit;

  // New fields for stats (nullable, as they might not always be part of basic user object)
  final int? totalWorkouts;
  final int? achievements; // e.g., number of badges/achievements unlocked

  // New profile attributes from setup flow
  final double? weight;
  final String? heightUnit;
  final double? height;
  final String? fitnessGoal;
  final String? experienceLevel;
  final List<String>? preferredTrainingDays;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool hasCompletedSetup; // Default to false

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.streakCount,
    this.role = UserRole.user,
    this.preferredWeightUnit = "kg", // This can serve as weightUnit
    this.preferredDistanceUnit = "km",
    this.totalWorkouts,
    this.achievements,
    this.weight,
    this.heightUnit,
    this.height,
    this.fitnessGoal,
    this.experienceLevel,
    this.preferredTrainingDays,
    this.dateOfBirth,
    this.gender,
    this.hasCompletedSetup = false, // Initialize with default
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      streakCount: json['streakCount'] as int? ?? 0,
      role: _userRoleFromString(json['role'] as String?),
      preferredWeightUnit: json['preferredWeightUnit'] as String? ?? 'kg',
      preferredDistanceUnit: json['preferredDistanceUnit'] as String? ?? 'km',
      totalWorkouts: json['totalWorkouts'] as int?,
      achievements: json['achievements'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      heightUnit: json['heightUnit'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      fitnessGoal: json['fitnessGoal'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      preferredTrainingDays: json['preferredTrainingDays'] != null
          ? List<String>.from(json['preferredTrainingDays'] as List<dynamic>)
          : null,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      hasCompletedSetup: json['hasCompletedSetup'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'streakCount': streakCount,
      'role': _userRoleToString(role),
      'preferredWeightUnit': preferredWeightUnit,
      'preferredDistanceUnit': preferredDistanceUnit,
      'totalWorkouts': totalWorkouts,
      'achievements': achievements,
      'weight': weight,
      'heightUnit': heightUnit,
      'height': height,
      'fitnessGoal': fitnessGoal,
      'experienceLevel': experienceLevel,
      'preferredTrainingDays': preferredTrainingDays,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'hasCompletedSetup': hasCompletedSetup,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    int? streakCount,
    UserRole? role,
    String? preferredWeightUnit,
    String? preferredDistanceUnit,
    int? totalWorkouts,
    int? achievements,
    double? weight,
    String? heightUnit,
    double? height,
    String? fitnessGoal,
    String? experienceLevel,
    List<String>? preferredTrainingDays,
    DateTime? dateOfBirth,
    String? gender,
    bool? hasCompletedSetup,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      streakCount: streakCount ?? this.streakCount,
      role: role ?? this.role,
      preferredWeightUnit: preferredWeightUnit ?? this.preferredWeightUnit,
      preferredDistanceUnit: preferredDistanceUnit ?? this.preferredDistanceUnit,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      achievements: achievements ?? this.achievements,
      weight: weight ?? this.weight,
      heightUnit: heightUnit ?? this.heightUnit,
      height: height ?? this.height,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      preferredTrainingDays: preferredTrainingDays ?? this.preferredTrainingDays,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }
}

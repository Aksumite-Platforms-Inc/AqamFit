import 'package:flutter/foundation.dart'; // For listEquals

enum ExerciseType {
  strength,
  cardio,
  stretch,
  plyometrics,
  // Add more as needed
}

class Exercise {
  final String id; // UUID
  final String name;
  final String description;
  final List<String> muscleGroups; // e.g., ["Chest", "Triceps", "Shoulders"]
  final List<String> equipment;    // e.g., ["Dumbbell", "Barbell", "Bench"]
  final ExerciseType type;
  final String? imageUrl; // Optional: path to local asset or network URL
  final String? videoUrl; // Optional: network URL (e.g., YouTube)

  Exercise({
    required this.id,
    required this.name,
    this.description = '',
    this.muscleGroups = const [],
    this.equipment = const [],
    required this.type,
    this.imageUrl,
    this.videoUrl,
  });

  // Factory constructor for creating a new Exercise instance from a map (e.g., from JSON)
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      muscleGroups: List<String>.from(json['muscleGroups'] as List<dynamic>? ?? []),
      equipment: List<String>.from(json['equipment'] as List<dynamic>? ?? []),
      type: ExerciseType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ExerciseType.strength, // Default type
      ),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  // Method for converting an Exercise instance to a map (e.g., for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroups': muscleGroups,
      'equipment': equipment,
      'type': type.toString(),
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  // For equality comparison, useful for tests and state management
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        listEquals(other.muscleGroups, muscleGroups) &&
        listEquals(other.equipment, equipment) &&
        other.type == type &&
        other.imageUrl == imageUrl &&
        other.videoUrl == videoUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      muscleGroups.hashCode ^
      equipment.hashCode ^
      type.hashCode ^
      imageUrl.hashCode ^
      videoUrl.hashCode;
}

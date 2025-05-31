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
  final String? imageUrl;
  final String? videoUrl;
  final int? durationSeconds; // Typical duration for timed exercises

  Exercise({
    required this.id,
    required this.name,
    this.description = '',
    this.muscleGroups = const [],
    this.equipment = const [],
    required this.type,
    this.imageUrl,
    this.videoUrl,
    this.durationSeconds, // Added optional field
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      muscleGroups: List<String>.from(json['muscleGroups'] as List<dynamic>? ?? []),
      equipment: List<String>.from(json['equipment'] as List<dynamic>? ?? []),
      type: ExerciseType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ExerciseType.strength,
      ),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int?, // Added
    );
  }

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
      'durationSeconds': durationSeconds, // Added
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
        other.videoUrl == videoUrl &&
        other.durationSeconds == durationSeconds; // Added
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
      videoUrl.hashCode ^
      durationSeconds.hashCode; // Added
}

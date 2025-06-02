import 'package:aksumfit/models/workout_plan_exercise.dart';
import 'package:flutter/foundation.dart'; // For listEquals

enum WorkoutPlanCategory {
  strength,
  hypertrophy,
  endurance,
  flexibility,
  functional,
  hiit,
  custom,
  // Add more as needed
}

extension WorkoutPlanCategoryExtension on WorkoutPlanCategory {
  String get displayName {
    switch (this) {
      case WorkoutPlanCategory.strength:
        return 'Strength';
      case WorkoutPlanCategory.hypertrophy:
        return 'Hypertrophy';
      case WorkoutPlanCategory.endurance:
        return 'Endurance';
      case WorkoutPlanCategory.flexibility:
        return 'Flexibility';
      case WorkoutPlanCategory.functional:
        return 'Functional';
      case WorkoutPlanCategory.hiit:
        return 'HIIT';
      case WorkoutPlanCategory.custom:
        return 'Custom';
      default:
        return name;
    }
  }
}

enum WorkoutDifficulty {
  beginner,
  intermediate,
  advanced,
  allLevels,
}

extension WorkoutDifficultyExtension on WorkoutDifficulty {
  String get displayName {
    switch (this) {
      case WorkoutDifficulty.beginner:
        return 'Beginner';
      case WorkoutDifficulty.intermediate:
        return 'Intermediate';
      case WorkoutDifficulty.advanced:
        return 'Advanced';
      case WorkoutDifficulty.allLevels:
        return 'All Levels';
      default:
        return name;
    }
  }
}

class WorkoutPlan {
  final String id; // UUID
  final String name;
  final String? description;
  final List<WorkoutPlanExercise> exercises;
  final WorkoutPlanCategory category;
  final WorkoutDifficulty difficulty;
  final int? estimatedDurationMinutes; // Optional, could be calculated
  final String authorId; // ID of the user who created it, or a system ID for predefined plans
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? tags; // Optional tags for the workout plan

  WorkoutPlan({
    required this.id,
    required this.name,
    this.description,
    this.exercises = const [],
    this.category = WorkoutPlanCategory.custom,
    this.difficulty = WorkoutDifficulty.allLevels,
    this.estimatedDurationMinutes,
    required this.authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.tags,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutPlanExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: WorkoutPlanCategory.values.firstWhere(
        (c) => c.toString() == json['category'],
        orElse: () => WorkoutPlanCategory.custom,
      ),
      difficulty: WorkoutDifficulty.values.firstWhere(
        (d) => d.toString() == json['difficulty'],
        orElse: () => WorkoutDifficulty.allLevels,
      ),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int?,
      authorId: json['authorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'category': category.toString(),
      'difficulty': difficulty.toString(),
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (tags != null) 'tags': tags,
    };
  }

  WorkoutPlan copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutPlanExercise>? exercises,
    WorkoutPlanCategory? category,
    WorkoutDifficulty? difficulty,
    int? estimatedDurationMinutes,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutPlan &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        listEquals(other.exercises, exercises) &&
        other.category == category &&
        other.difficulty == difficulty &&
        other.estimatedDurationMinutes == estimatedDurationMinutes &&
        other.authorId == authorId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      exercises.hashCode ^
      category.hashCode ^
      difficulty.hashCode ^
      estimatedDurationMinutes.hashCode ^
      authorId.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}

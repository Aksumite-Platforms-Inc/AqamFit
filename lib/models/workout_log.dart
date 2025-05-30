import 'package:aksumfit/models/logged_exercise.dart';
import 'package:flutter/foundation.dart'; // For listEquals

class WorkoutLog {
  final String id; // UUID for the log entry
  final String userId; // ID of the user who logged this workout
  final String? planId; // Optional: ID of the WorkoutPlan followed
  final String? planName; // Optional: Denormalized name of the plan for quick display

  final DateTime startTime;
  final DateTime endTime;
  final List<LoggedExercise> completedExercises;

  final String? notes; // Overall notes for the entire workout session
  final int? caloriesBurned; // Optional: Estimated calories burned
  final String? location; // Optional: e.g., "Gym", "Home"

  WorkoutLog({
    required this.id,
    required this.userId,
    this.planId,
    this.planName,
    required this.startTime,
    required this.endTime,
    this.completedExercises = const [],
    this.notes,
    this.caloriesBurned,
    this.location,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String?,
      planName: json['planName'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      completedExercises: (json['completedExercises'] as List<dynamic>? ?? [])
          .map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      caloriesBurned: json['caloriesBurned'] as int?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'completedExercises': completedExercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'caloriesBurned': caloriesBurned,
      'location': location,
    };
  }

  WorkoutLog copyWith({
    String? id,
    String? userId,
    String? planId,
    String? planName,
    DateTime? startTime,
    DateTime? endTime,
    List<LoggedExercise>? completedExercises,
    String? notes,
    int? caloriesBurned,
    String? location,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedExercises: completedExercises ?? this.completedExercises,
      notes: notes ?? this.notes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutLog &&
        other.id == id &&
        other.userId == userId &&
        other.planId == planId &&
        other.planName == planName &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        listEquals(other.completedExercises, completedExercises) &&
        other.notes == notes &&
        other.caloriesBurned == caloriesBurned &&
        other.location == location;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      planId.hashCode ^
      planName.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      completedExercises.hashCode ^
      notes.hashCode ^
      caloriesBurned.hashCode ^
      location.hashCode;
}

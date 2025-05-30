import 'package:aksumfit/models/logged_set.dart';
import 'package:flutter/foundation.dart'; // For listEquals

class LoggedExercise {
  final String id; // Unique ID for this logged instance
  final String exerciseId; // Original Exercise.id
  final String exerciseName; // Denormalized for convenience
  final List<LoggedSet> sets;
  final int? durationAchievedSeconds; // If the entire exercise was one timed block (e.g. Plank)
  final String? notes; // Overall notes for this exercise in the log

  LoggedExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.sets = const [],
    this.durationAchievedSeconds,
    this.notes,
  });

  factory LoggedExercise.fromJson(Map<String, dynamic> json) {
    return LoggedExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List<dynamic>? ?? [])
          .map((s) => LoggedSet.fromJson(s as Map<String, dynamic>))
          .toList(),
      durationAchievedSeconds: json['durationAchievedSeconds'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((s) => s.toJson()).toList(),
      'durationAchievedSeconds': durationAchievedSeconds,
      'notes': notes,
    };
  }

  LoggedExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    List<LoggedSet>? sets,
    int? durationAchievedSeconds,
    String? notes,
  }) {
    return LoggedExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      durationAchievedSeconds: durationAchievedSeconds ?? this.durationAchievedSeconds,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoggedExercise &&
        other.id == id &&
        other.exerciseId == exerciseId &&
        other.exerciseName == exerciseName &&
        listEquals(other.sets, sets) &&
        other.durationAchievedSeconds == durationAchievedSeconds &&
        other.notes == notes;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      exerciseId.hashCode ^
      exerciseName.hashCode ^
      sets.hashCode ^
      durationAchievedSeconds.hashCode ^
      notes.hashCode;
}

import 'package:aksumfit/models/exercise.dart'; // Assuming Exercise model is in exercise.dart
import 'package:flutter/foundation.dart'; // For listEquals, if needed for future complex fields

class WorkoutPlanExercise {
  final String id; // Unique ID for this specific instance in the plan
  final String exerciseId; // References Exercise.id
  final int order; // Sequence in the workout plan

  // Performance parameters
  final int? sets; // For strength exercises
  final String? reps; // e.g., "8-12", "AMRAP", "5x5" (for strength)
  final double? weightKg; // Weight in kilograms (for strength)
  final int? durationSeconds; // For timed exercises or timed sets
  final int? restBetweenSetsSeconds; // Rest time after each set

  final String? notes; // User notes for this specific exercise in the plan

  // Optional: Denormalized Exercise details for easier access,
  // especially if not using a relational DB locally.
  // Be cautious with denormalization; it can lead to data inconsistency if not managed.
  final Exercise? exerciseDetails;

  WorkoutPlanExercise({
    required this.id,
    required this.exerciseId,
    required this.order,
    this.sets,
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.restBetweenSetsSeconds,
    this.notes,
    this.exerciseDetails,
  });

  factory WorkoutPlanExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      order: json['order'] as int,
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      durationSeconds: json['durationSeconds'] as int?,
      restBetweenSetsSeconds: json['restBetweenSetsSeconds'] as int?,
      notes: json['notes'] as String?,
      exerciseDetails: json['exerciseDetails'] != null
          ? Exercise.fromJson(json['exerciseDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'order': order,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'durationSeconds': durationSeconds,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'notes': notes,
      'exerciseDetails': exerciseDetails?.toJson(),
    };
  }

  // CopyWith method for easier updates (immutability)
  WorkoutPlanExercise copyWith({
    String? id,
    String? exerciseId,
    int? order,
    int? sets,
    String? reps,
    double? weightKg,
    int? durationSeconds,
    int? restBetweenSetsSeconds,
    String? notes,
    Exercise? exerciseDetails,
    bool clearExerciseDetails = false, // To explicitly nullify exerciseDetails
  }) {
    return WorkoutPlanExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restBetweenSetsSeconds: restBetweenSetsSeconds ?? this.restBetweenSetsSeconds,
      notes: notes ?? this.notes,
      exerciseDetails: clearExerciseDetails ? null : (exerciseDetails ?? this.exerciseDetails),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutPlanExercise &&
        other.id == id &&
        other.exerciseId == exerciseId &&
        other.order == order &&
        other.sets == sets &&
        other.reps == reps &&
        other.weightKg == weightKg &&
        other.durationSeconds == durationSeconds &&
        other.restBetweenSetsSeconds == restBetweenSetsSeconds &&
        other.notes == notes &&
        other.exerciseDetails == exerciseDetails; // Relies on Exercise's == operator
  }

  @override
  int get hashCode =>
      id.hashCode ^
      exerciseId.hashCode ^
      order.hashCode ^
      sets.hashCode ^
      reps.hashCode ^
      weightKg.hashCode ^
      durationSeconds.hashCode ^
      restBetweenSetsSeconds.hashCode ^
      notes.hashCode ^
      exerciseDetails.hashCode;
}

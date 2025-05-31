import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Enum for types of metrics a goal can be set for
enum GoalMetricType {
  weight, // Target body weight
  bodyFatPercentage,
  muscleMass,
  waistCircumference,
  // Add other body measurements as needed

  exerciseMaxWeight, // Target max weight for a specific exercise
  exerciseMaxReps,   // Target max reps for a specific exercise
  exerciseFastestTime, // Target time for a timed exercise/run
  // Add other performance metrics

  workoutFrequency, // e.g., number of workouts per week
  totalCaloriesLogged, // For nutrition goals (daily or weekly)
  custom,
}

class Goal {
  final String id;
  final String userId;
  final String name; // User-defined name for the goal, e.g., "Lose 5kg", "Bench 100kg"
  final GoalMetricType metricType;

  final String? exerciseName; // Relevant if metricType is exercise-specific
  final String? metricUnit;   // e.g., "kg", "%", "reps", "seconds", "workouts/week"

  final double targetValue;
  final double startValue; // Value when the goal was set
  double currentValue; // Latest recorded value for this metric, updated by a listener/service

  final DateTime startDate;
  final DateTime? targetDate; // Optional target date for achieving the goal
  final bool isActive; // Is this goal currently being pursued?
  final DateTime createdAt;
  DateTime updatedAt;

  Goal({
    String? id,
    required this.userId,
    required this.name,
    required this.metricType,
    this.exerciseName,
    this.metricUnit,
    required this.targetValue,
    required this.startValue,
    required this.currentValue, // Should be initialized with startValue or fetched
    required this.startDate,
    this.targetDate,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      metricType: GoalMetricType.values.firstWhere(
        (e) => e.toString() == json['metricType'],
        orElse: () => GoalMetricType.custom,
      ),
      exerciseName: json['exerciseName'] as String?,
      metricUnit: json['metricUnit'] as String?,
      targetValue: (json['targetValue'] as num).toDouble(),
      startValue: (json['startValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate'] as String) : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'metricType': metricType.toString(),
      'exerciseName': exerciseName,
      'metricUnit': metricUnit,
      'targetValue': targetValue,
      'startValue': startValue,
      'currentValue': currentValue,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? name,
    GoalMetricType? metricType,
    String? exerciseName,
    String? metricUnit,
    double? targetValue,
    double? startValue,
    double? currentValue,
    DateTime? startDate,
    DateTime? targetDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      metricType: metricType ?? this.metricType,
      exerciseName: exerciseName ?? this.exerciseName,
      metricUnit: metricUnit ?? this.metricUnit,
      targetValue: targetValue ?? this.targetValue,
      startValue: startValue ?? this.startValue,
      currentValue: currentValue ?? this.currentValue,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper to calculate progress
  double get progressPercentage {
    if (targetValue == startValue) return currentValue >= targetValue ? 1.0 : 0.0; // Avoid division by zero
    double progress = ((currentValue - startValue) / (targetValue - startValue)).clamp(0.0, 1.0);
    return progress;
  }

  bool get isAchieved => (targetValue > startValue && currentValue >= targetValue) || (targetValue < startValue && currentValue <= targetValue);
}

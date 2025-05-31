import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Enum for common metric types, can be expanded
enum PerformanceMetricType {
  maxWeight,      // For lifts like Bench Press, Squat (value = weight in kg/lbs)
  maxReps,        // Reps at a specific weight, or bodyweight (value = reps)
  fastestTime,    // For sprints, timed runs (value = time in seconds)
  maxDistance,    // For distance-based cardio (value = distance in km/miles)
  longestDuration,// For endurance holds like Plank (value = time in seconds)
  custom,         // For user-defined metrics
}

class PerformanceMetricEntry {
  final String id;
  final DateTime date;
  final String userId;

  final String exerciseName; // e.g., "Bench Press", "5K Run", "Plank"
                           // Could be linked to an Exercise.id in a more complex system
  final PerformanceMetricType metricType;
  final double value;      // The actual metric value
  final String? unit;      // e.g., "kg", "lbs", "reps", "seconds", "minutes", "km", "miles"
  final String? notes;

  PerformanceMetricEntry({
    String? id,
    required this.date,
    required this.userId,
    required this.exerciseName,
    required this.metricType,
    required this.value,
    this.unit,
    this.notes,
  }) : id = id ?? _uuid.v4();

  factory PerformanceMetricEntry.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      userId: json['userId'] as String,
      exerciseName: json['exerciseName'] as String,
      metricType: PerformanceMetricType.values.firstWhere(
        (e) => e.toString() == json['metricType'],
        orElse: () => PerformanceMetricType.custom,
      ),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'userId': userId,
      'exerciseName': exerciseName,
      'metricType': metricType.toString(),
      'value': value,
      'unit': unit,
      'notes': notes,
    };
  }

  PerformanceMetricEntry copyWith({
    String? id,
    DateTime? date,
    String? userId,
    String? exerciseName,
    PerformanceMetricType? metricType,
    double? value,
    String? unit,
    String? notes,
  }) {
    return PerformanceMetricEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      exerciseName: exerciseName ?? this.exerciseName,
      metricType: metricType ?? this.metricType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceMetricEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper for display
  String get metricTypeDisplay {
    // Example: PerformanceMetricType.maxWeight -> "Max Weight"
    return metricType.toString().split('.').last.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim();
  }

  String get valueWithUnit {
    return "$value ${unit ?? ''}".trim();
  }
}

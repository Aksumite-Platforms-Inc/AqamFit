import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class WeightEntry {
  final String id;
  final DateTime date;
  final double weightKg;
  final String? notes;
  final String userId;

  WeightEntry({
    String? id,
    required this.date,
    required this.weightKg,
    this.notes,
    required this.userId,
  }) : id = id ?? _uuid.v4();

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      notes: json['notes'] as String?,
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'notes': notes,
      'userId': userId,
    };
  }

  WeightEntry copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    String? notes,
    String? userId,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightEntry &&
        other.id == id &&
        other.date == date &&
        other.weightKg == weightKg &&
        other.notes == notes &&
        other.userId == userId;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      date.hashCode ^
      weightKg.hashCode ^
      notes.hashCode ^
      userId.hashCode;
}

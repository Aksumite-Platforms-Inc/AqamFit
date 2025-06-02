// For @required in older Flutter versions, or for general utility.

class PersonalRecord {
  final String id;
  final String userId;
  final String exerciseName;
  final String recordType; // e.g., "1 Rep Max", "Max Reps", "Fastest 5k", "Longest Plank"
  final String value;      // e.g., "100 kg", "15 reps", "25:30", "3 min"
  final DateTime dateAchieved;

  PersonalRecord({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.recordType,
    required this.value,
    required this.dateAchieved,
  });

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      exerciseName: json['exerciseName'] as String,
      recordType: json['recordType'] as String,
      value: json['value'] as String,
      dateAchieved: DateTime.parse(json['dateAchieved'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseName': exerciseName,
      'recordType': recordType,
      'value': value,
      'dateAchieved': dateAchieved.toIso8601String(),
    };
  }

  PersonalRecord copyWith({
    String? id,
    String? userId,
    String? exerciseName,
    String? recordType,
    String? value,
    DateTime? dateAchieved,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseName: exerciseName ?? this.exerciseName,
      recordType: recordType ?? this.recordType,
      value: value ?? this.value,
      dateAchieved: dateAchieved ?? this.dateAchieved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          exerciseName == other.exerciseName &&
          recordType == other.recordType &&
          value == other.value &&
          dateAchieved == other.dateAchieved;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      exerciseName.hashCode ^
      recordType.hashCode ^
      value.hashCode ^
      dateAchieved.hashCode;

  @override
  String toString() {
    return 'PersonalRecord{id: $id, userId: $userId, exerciseName: $exerciseName, recordType: $recordType, value: $value, dateAchieved: $dateAchieved}';
  }
}

class LoggedSet {
  final int setNumber;
  final int? repsAchieved;
  final double? weightUsedKg; // Weight in kilograms
  final int? durationAchievedSeconds; // For timed sets
  final bool isCompleted;
  final String? notes;

  LoggedSet({
    required this.setNumber,
    this.repsAchieved,
    this.weightUsedKg,
    this.durationAchievedSeconds,
    this.isCompleted = false,
    this.notes,
  });

  factory LoggedSet.fromJson(Map<String, dynamic> json) {
    return LoggedSet(
      setNumber: json['setNumber'] as int,
      repsAchieved: json['repsAchieved'] as int?,
      weightUsedKg: (json['weightUsedKg'] as num?)?.toDouble(),
      durationAchievedSeconds: json['durationAchievedSeconds'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'repsAchieved': repsAchieved,
      'weightUsedKg': weightUsedKg,
      'durationAchievedSeconds': durationAchievedSeconds,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  LoggedSet copyWith({
    int? setNumber,
    int? repsAchieved,
    double? weightUsedKg,
    int? durationAchievedSeconds,
    bool? isCompleted,
    String? notes,
  }) {
    return LoggedSet(
      setNumber: setNumber ?? this.setNumber,
      repsAchieved: repsAchieved ?? this.repsAchieved,
      weightUsedKg: weightUsedKg ?? this.weightUsedKg,
      durationAchievedSeconds: durationAchievedSeconds ?? this.durationAchievedSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoggedSet &&
        other.setNumber == setNumber &&
        other.repsAchieved == repsAchieved &&
        other.weightUsedKg == weightUsedKg &&
        other.durationAchievedSeconds == durationAchievedSeconds &&
        other.isCompleted == isCompleted &&
        other.notes == notes;
  }

  @override
  int get hashCode =>
      setNumber.hashCode ^
      repsAchieved.hashCode ^
      weightUsedKg.hashCode ^
      durationAchievedSeconds.hashCode ^
      isCompleted.hashCode ^
      notes.hashCode;
}

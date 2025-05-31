import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class BodyMeasurementEntry {
  final String id;
  final DateTime date;
  final String userId;

  final double? bodyFatPercentage;
  final double? muscleMassKg;
  final double? waistCircumferenceCm;
  final double? chestCircumferenceCm;
  final double? hipCircumferenceCm;
  final double? neckCircumferenceCm;
  final double? armCircumferenceCm; // e.g., biceps relaxed or flexed
  final double? thighCircumferenceCm;
  final double? calfCircumferenceCm;

  final String? notes;

  BodyMeasurementEntry({
    String? id,
    required this.date,
    required this.userId,
    this.bodyFatPercentage,
    this.muscleMassKg,
    this.waistCircumferenceCm,
    this.chestCircumferenceCm,
    this.hipCircumferenceCm,
    this.neckCircumferenceCm,
    this.armCircumferenceCm,
    this.thighCircumferenceCm,
    this.calfCircumferenceCm,
    this.notes,
  }) : id = id ?? _uuid.v4();

  factory BodyMeasurementEntry.fromJson(Map<String, dynamic> json) {
    return BodyMeasurementEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      userId: json['userId'] as String,
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      muscleMassKg: (json['muscleMassKg'] as num?)?.toDouble(),
      waistCircumferenceCm: (json['waistCircumferenceCm'] as num?)?.toDouble(),
      chestCircumferenceCm: (json['chestCircumferenceCm'] as num?)?.toDouble(),
      hipCircumferenceCm: (json['hipCircumferenceCm'] as num?)?.toDouble(),
      neckCircumferenceCm: (json['neckCircumferenceCm'] as num?)?.toDouble(),
      armCircumferenceCm: (json['armCircumferenceCm'] as num?)?.toDouble(),
      thighCircumferenceCm: (json['thighCircumferenceCm'] as num?)?.toDouble(),
      calfCircumferenceCm: (json['calfCircumferenceCm'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'userId': userId,
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMassKg': muscleMassKg,
      'waistCircumferenceCm': waistCircumferenceCm,
      'chestCircumferenceCm': chestCircumferenceCm,
      'hipCircumferenceCm': hipCircumferenceCm,
      'neckCircumferenceCm': neckCircumferenceCm,
      'armCircumferenceCm': armCircumferenceCm,
      'thighCircumferenceCm': thighCircumferenceCm,
      'calfCircumferenceCm': calfCircumferenceCm,
      'notes': notes,
    };
  }

  BodyMeasurementEntry copyWith({
    String? id,
    DateTime? date,
    String? userId,
    double? bodyFatPercentage,
    double? muscleMassKg,
    double? waistCircumferenceCm,
    double? chestCircumferenceCm,
    double? hipCircumferenceCm,
    double? neckCircumferenceCm,
    double? armCircumferenceCm,
    double? thighCircumferenceCm,
    double? calfCircumferenceCm,
    String? notes,
  }) {
    return BodyMeasurementEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMassKg: muscleMassKg ?? this.muscleMassKg,
      waistCircumferenceCm: waistCircumferenceCm ?? this.waistCircumferenceCm,
      chestCircumferenceCm: chestCircumferenceCm ?? this.chestCircumferenceCm,
      hipCircumferenceCm: hipCircumferenceCm ?? this.hipCircumferenceCm,
      neckCircumferenceCm: neckCircumferenceCm ?? this.neckCircumferenceCm,
      armCircumferenceCm: armCircumferenceCm ?? this.armCircumferenceCm,
      thighCircumferenceCm: thighCircumferenceCm ?? this.thighCircumferenceCm,
      calfCircumferenceCm: calfCircumferenceCm ?? this.calfCircumferenceCm,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BodyMeasurementEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper to check if any measurement value is present
  bool get hasAnyMeasurementValue {
    return bodyFatPercentage != null ||
        muscleMassKg != null ||
        waistCircumferenceCm != null ||
        chestCircumferenceCm != null ||
        hipCircumferenceCm != null ||
        neckCircumferenceCm != null ||
        armCircumferenceCm != null ||
        thighCircumferenceCm != null ||
        calfCircumferenceCm != null;
  }
}

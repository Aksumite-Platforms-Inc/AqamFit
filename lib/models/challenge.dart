import 'package:flutter/foundation.dart'; // For @required if needed, or general utility.
import 'package:uuid/uuid.dart';

class Challenge {
  final String id;
  final String name;
  final String description;
  final String? imageUrl; // Optional image for the challenge
  final int participantCount;
  final DateTime endDate;
  final String type; // e.g., "MostWorkouts", "TotalDistance", "WeightLossPercentage"
  final double targetValue; // e.g., 20 (workouts), 100 (km), 5 (%)
  final String unit; // e.g., "workouts", "km", "%"
  final bool isFeatured;
  final bool isHot;

  Challenge({
    String? id, // Allow optional ID for auto-generation
    required this.name,
    required this.description,
    this.imageUrl,
    required this.participantCount,
    required this.endDate,
    required this.type,
    required this.targetValue,
    required this.unit,
    this.isFeatured = false,
    this.isHot = false,
  }) : id = id ?? Uuid().v4(); // Auto-generate ID if not provided


  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      participantCount: json['participantCount'] as int? ?? 0,
      endDate: DateTime.parse(json['endDate'] as String),
      type: json['type'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      unit: json['unit'] as String,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isHot: json['isHot'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'participantCount': participantCount,
    'endDate': endDate.toIso8601String(),
    'type': type,
    'targetValue': targetValue,
    'unit': unit,
    'isFeatured': isFeatured,
    'isHot': isHot,
  };

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    ValueGetter<String?>? imageUrl, // Use ValueGetter for nullable fields to distinguish between null and not provided
    int? participantCount,
    DateTime? endDate,
    String? type,
    double? targetValue,
    String? unit,
    bool? isFeatured,
    bool? isHot,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      participantCount: participantCount ?? this.participantCount,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      isFeatured: isFeatured ?? this.isFeatured,
      isHot: isHot ?? this.isHot,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Challenge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          participantCount == other.participantCount &&
          endDate == other.endDate &&
          type == other.type &&
          targetValue == other.targetValue &&
          unit == other.unit &&
          isFeatured == other.isFeatured &&
          isHot == other.isHot;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      participantCount.hashCode ^
      endDate.hashCode ^
      type.hashCode ^
      targetValue.hashCode ^
      unit.hashCode ^
      isFeatured.hashCode ^
      isHot.hashCode;

  @override
  String toString() {
    return 'Challenge{id: $id, name: $name, description: $description, imageUrl: $imageUrl, participantCount: $participantCount, endDate: $endDate, type: $type, targetValue: $targetValue, unit: $unit, isFeatured: $isFeatured, isHot: $isHot}';
  }
}

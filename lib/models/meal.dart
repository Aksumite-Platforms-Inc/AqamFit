import 'package:aksumfit/models/meal_item.dart';
import 'package:flutter/foundation.dart'; // For listEquals
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  other,
}

class Meal {
  final String id; // UUID
  final MealType type;
  final List<MealItem> items;
  final DateTime loggedAt; // Timestamp for when the meal was recorded or intended

  // Calculated totals for the meal
  final double totalCalories;
  final double totalProteinGrams;
  final double totalCarbGrams;
  final double totalFatGrams;

  Meal({
    String? id,
    required this.type,
    List<MealItem>? items,
    DateTime? loggedAt,
  })  : this.id = id ?? _uuid.v4(),
        this.items = items ?? [],
        this.loggedAt = loggedAt ?? DateTime.now(),
        // Calculate totals upon instantiation
        totalCalories = (items ?? []).fold(0, (sum, item) => sum + item.caloriesConsumed),
        totalProteinGrams = (items ?? []).fold(0, (sum, item) => sum + item.proteinConsumedGrams),
        totalCarbGrams = (items ?? []).fold(0, (sum, item) => sum + item.carbConsumedGrams),
        totalFatGrams = (items ?? []).fold(0, (sum, item) => sum + item.fatConsumedGrams);

  factory Meal.fromJson(Map<String, dynamic> json) {
    // This factory assumes that calculated totals are stored in JSON or can be recalculated.
    // For simplicity, we recalculate from items if totals aren't explicitly stored.
    List<MealItem> mealItems = (json['items'] as List<dynamic>? ?? [])
        .map((itemJson) => MealItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    return Meal(
      id: json['id'] as String,
      type: MealType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MealType.other,
      ),
      items: mealItems,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      // Recalculation ensures consistency, but if performance is critical for large lists,
      // you might store and retrieve these totals directly.
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'items': items.map((item) => item.toJson()).toList(),
      'loggedAt': loggedAt.toIso8601String(),
      // Store calculated totals for convenience
      'totalCalories': totalCalories,
      'totalProteinGrams': totalProteinGrams,
      'totalCarbGrams': totalCarbGrams,
      'totalFatGrams': totalFatGrams,
    };
  }

  Meal copyWith({
    String? id,
    MealType? type,
    List<MealItem>? items,
    DateTime? loggedAt,
    // Totals are not in copyWith as they are derived from items
  }) {
    return Meal(
      id: id ?? this.id,
      type: type ?? this.type,
      items: items ?? this.items,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meal &&
        other.id == id &&
        other.type == type &&
        listEquals(other.items, items) &&
        other.loggedAt == loggedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      items.hashCode ^
      loggedAt.hashCode;
}

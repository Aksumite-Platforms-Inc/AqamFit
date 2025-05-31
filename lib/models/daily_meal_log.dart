import 'package:aksumfit/models/meal.dart';
import 'package:flutter/foundation.dart'; // For listEquals
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class DailyMealLog {
  final String id; // UUID
  final String userId;
  final DateTime date; // Date for which these meals are logged (midnight UTC)
  final List<Meal> meals; // List of meals for this day

  // Calculated daily totals
  final double dailyTotalCalories;
  final double dailyTotalProteinGrams;
  final double dailyTotalCarbGrams;
  final double dailyTotalFatGrams;

  final String? notes; // Optional notes for the day

  DailyMealLog({
    String? id,
    required this.userId,
    required this.date,
    List<Meal>? meals,
    this.notes,
  }) : id = id ?? _uuid.v4(),
       meals = meals ?? [],
       // Calculate daily totals upon instantiation
       dailyTotalCalories = (meals ?? []).fold(0, (sum, meal) => sum + meal.totalCalories),
       dailyTotalProteinGrams = (meals ?? []).fold(0, (sum, meal) => sum + meal.totalProteinGrams),
       dailyTotalCarbGrams = (meals ?? []).fold(0, (sum, meal) => sum + meal.totalCarbGrams),
       dailyTotalFatGrams = (meals ?? []).fold(0, (sum, meal) => sum + meal.totalFatGrams);

  factory DailyMealLog.fromJson(Map<String, dynamic> json) {
    List<Meal> mealEntries = (json['meals'] as List<dynamic>? ?? [])
        .map((mealJson) => Meal.fromJson(mealJson as Map<String, dynamic>))
        .toList();

    return DailyMealLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      meals: mealEntries,
      notes: json['notes'] as String?,
      // Recalculate totals for consistency, or trust stored values if present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(), // Store date as ISO8601 string (typically YYYY-MM-DDTHH:mm:ss.sssZ)
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'notes': notes,
      // Store calculated daily totals
      'dailyTotalCalories': dailyTotalCalories,
      'dailyTotalProteinGrams': dailyTotalProteinGrams,
      'dailyTotalCarbGrams': dailyTotalCarbGrams,
      'dailyTotalFatGrams': dailyTotalFatGrams,
    };
  }

  DailyMealLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<Meal>? meals,
    String? notes,
    // Totals are derived
  }) {
    return DailyMealLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyMealLog &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        listEquals(other.meals, meals);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      date.hashCode ^
      meals.hashCode;
}

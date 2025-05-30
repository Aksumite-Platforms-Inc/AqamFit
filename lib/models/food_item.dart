import 'package:flutter/foundation.dart'; // For listEquals, if used for complex fields later

enum FoodItemCategory {
  fruit, vegetable, grain, protein, dairy, fat, beverage, snack, other
}

class FoodItem {
  final String id; // UUID
  final String name;
  final String brand; // Optional, e.g., "Generic" or "BrandX"

  // Standard serving size information from the database
  final double servingSizeQuantity; // e.g., 100
  final String servingSizeUnit;   // e.g., "g", "ml", "piece", "slice"

  // Nutritional information per standard serving size
  final double calories;        // kcal
  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;

  // Optional further details
  final double? fiberGrams;
  final double? sugarGrams;
  final double? sodiumMg;
  // Add other micronutrients as needed, e.g., vitamins, minerals

  final FoodItemCategory category;
  final bool isCustom; // True if user-defined, false if from a general database

  FoodItem({
    required this.id,
    required this.name,
    this.brand = '',
    required this.servingSizeQuantity,
    required this.servingSizeUnit,
    required this.calories,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    this.fiberGrams,
    this.sugarGrams,
    this.sodiumMg,
    this.category = FoodItemCategory.other,
    this.isCustom = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String? ?? '',
      servingSizeQuantity: (json['servingSizeQuantity'] as num).toDouble(),
      servingSizeUnit: json['servingSizeUnit'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteinGrams: (json['proteinGrams'] as num).toDouble(),
      carbGrams: (json['carbGrams'] as num).toDouble(),
      fatGrams: (json['fatGrams'] as num).toDouble(),
      fiberGrams: (json['fiberGrams'] as num?)?.toDouble(),
      sugarGrams: (json['sugarGrams'] as num?)?.toDouble(),
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble(),
      category: FoodItemCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => FoodItemCategory.other,
      ),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'servingSizeQuantity': servingSizeQuantity,
      'servingSizeUnit': servingSizeUnit,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbGrams': carbGrams,
      'fatGrams': fatGrams,
      'fiberGrams': fiberGrams,
      'sugarGrams': sugarGrams,
      'sodiumMg': sodiumMg,
      'category': category.toString(),
      'isCustom': isCustom,
    };
  }

  // Helper to get a human-readable serving size string
  String get servingSizeDisplay => "$servingSizeQuantity $servingSizeUnit";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem && other.id == id; // ID is usually enough for entities
  }

  @override
  int get hashCode => id.hashCode;
}

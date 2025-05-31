import 'package:aksumfit/models/food_item.dart'; // Assuming FoodItem model is in food_item.dart
import 'package:uuid/uuid.dart'; // For generating unique IDs

const _uuid = Uuid();

class MealItem {
  final String id; // Unique ID for this meal item instance
  final FoodItem baseFoodItem; // The reference food item from the database or custom entry

  // User-defined quantity for this specific meal entry
  final double loggedQuantity;    // e.g., 2, 1.5, 0.75
  final String loggedUnit;      // e.g., "piece", "serving", "g", "ml"
                                // This can be different from baseFoodItem.servingSizeUnit

  // Calculated nutritional values for the loggedQuantity
  // These are calculated at the time of logging or creation.
  final double caloriesConsumed;
  final double proteinConsumedGrams;
  final double carbConsumedGrams;
  final double fatConsumedGrams;

  MealItem({
    String? id, // Allow providing an ID, or generate one
    required this.baseFoodItem,
    required this.loggedQuantity,
    required this.loggedUnit,
  }) : id = id ?? _uuid.v4(),
       // Perform calculations upon instantiation
       caloriesConsumed = (baseFoodItem.calories / baseFoodItem.servingSizeQuantity) * loggedQuantity * _getConversionFactor(loggedUnit, baseFoodItem.servingSizeUnit, baseFoodItem.servingSizeQuantity),
       proteinConsumedGrams = (baseFoodItem.proteinGrams / baseFoodItem.servingSizeQuantity) * loggedQuantity * _getConversionFactor(loggedUnit, baseFoodItem.servingSizeUnit, baseFoodItem.servingSizeQuantity),
       carbConsumedGrams = (baseFoodItem.carbGrams / baseFoodItem.servingSizeQuantity) * loggedQuantity * _getConversionFactor(loggedUnit, baseFoodItem.servingSizeUnit, baseFoodItem.servingSizeQuantity),
       fatConsumedGrams = (baseFoodItem.fatGrams / baseFoodItem.servingSizeQuantity) * loggedQuantity * _getConversionFactor(loggedUnit, baseFoodItem.servingSizeUnit, baseFoodItem.servingSizeQuantity);

  // Basic conversion factor - this needs to be significantly more robust in a real app
  // For example, "1 piece" to "grams" requires specific data for each FoodItem.
  // For now, we assume if units are different, it's a 1:1 for quantity if not 'g' or 'ml'
  // This is a simplification and a major area for future improvement with a proper unit conversion library/service.
  static double _getConversionFactor(String loggedUnit, String baseUnit, double baseQuantity) {
    if (loggedUnit == baseUnit) {
      return 1.0;
    }
    // Example: if base is "100 g" and logged is "g", factor is 1.0 (handled by dividing by baseQuantity then multiplying by loggedQuantity)
    // If base is "1 piece" (let's say baseQuantity is 1 for "piece") and logged is "piece", factor is 1.0.
    // This placeholder doesn't handle complex conversions like "cup" to "g" without more data.
    // For simplicity, if units don't match and it's not a direct scaling of the base unit quantity, assume direct multiplier.
    // A real app needs a database of conversion factors (e.g. 1 cup of flour in grams).
    return 1.0; // Placeholder - assumes loggedQuantity is in terms of baseFoodItem's servingSizeUnit if units mismatch
  }


  factory MealItem.fromJson(Map<String, dynamic> json) {
    // This factory assumes that calculated values are already stored in JSON.
    // If only baseFoodItem and loggedQuantity/Unit are stored, calculations must happen here.
    return MealItem(
      id: json['id'] as String,
      baseFoodItem: FoodItem.fromJson(json['baseFoodItem'] as Map<String, dynamic>),
      loggedQuantity: (json['loggedQuantity'] as num).toDouble(),
      loggedUnit: json['loggedUnit'] as String,
      // The constructor will recalculate these, so direct fromJson might be tricky unless values are stored
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseFoodItem': baseFoodItem.toJson(),
      'loggedQuantity': loggedQuantity,
      'loggedUnit': loggedUnit,
      // Store calculated values too, for simplicity in retrieval
      'caloriesConsumed': caloriesConsumed,
      'proteinConsumedGrams': proteinConsumedGrams,
      'carbConsumedGrams': carbConsumedGrams,
      'fatConsumedGrams': fatConsumedGrams,
    };
  }

  MealItem copyWith({
    String? id,
    FoodItem? baseFoodItem,
    double? loggedQuantity,
    String? loggedUnit,
    // Calculated fields are not directly copied, they re-calculate
  }) {
    return MealItem(
      id: id ?? this.id,
      baseFoodItem: baseFoodItem ?? this.baseFoodItem,
      loggedQuantity: loggedQuantity ?? this.loggedQuantity,
      loggedUnit: loggedUnit ?? this.loggedUnit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

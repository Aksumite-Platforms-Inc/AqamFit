import 'package:aksumfit/models/food_item.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final List<FoodItem> mockFoodDatabase = [
  // Fruits
  FoodItem(
    id: _uuid.v4(),
    name: "Apple",
    brand: "Generic",
    servingSizeQuantity: 1,
    servingSizeUnit: "medium piece", // approx 182g
    calories: 95,
    proteinGrams: 0.5,
    carbGrams: 25,
    fatGrams: 0.3,
    fiberGrams: 4.4,
    sugarGrams: 19,
    category: FoodItemCategory.fruit,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Banana",
    brand: "Generic",
    servingSizeQuantity: 1,
    servingSizeUnit: "medium piece", // approx 118g
    calories: 105,
    proteinGrams: 1.3,
    carbGrams: 27,
    fatGrams: 0.4,
    fiberGrams: 3.1,
    sugarGrams: 14,
    category: FoodItemCategory.fruit,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Orange",
    servingSizeQuantity: 1,
    servingSizeUnit: "medium piece", // approx 131g
    calories: 62,
    proteinGrams: 1.2,
    carbGrams: 15,
    fatGrams: 0.2,
    category: FoodItemCategory.fruit,
  ),

  // Vegetables
  FoodItem(
    id: _uuid.v4(),
    name: "Broccoli",
    servingSizeQuantity: 100,
    servingSizeUnit: "g",
    calories: 34,
    proteinGrams: 2.8,
    carbGrams: 7,
    fatGrams: 0.4,
    category: FoodItemCategory.vegetable,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Spinach",
    servingSizeQuantity: 100,
    servingSizeUnit: "g",
    calories: 23,
    proteinGrams: 2.9,
    carbGrams: 3.6,
    fatGrams: 0.4,
    category: FoodItemCategory.vegetable,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Carrot",
    servingSizeQuantity: 1,
    servingSizeUnit: "medium piece", // approx 61g
    calories: 25,
    proteinGrams: 0.6,
    carbGrams: 6,
    fatGrams: 0.1,
    category: FoodItemCategory.vegetable,
  ),

  // Proteins
  FoodItem(
    id: _uuid.v4(),
    name: "Chicken Breast",
    brand: "Generic, Cooked",
    servingSizeQuantity: 100,
    servingSizeUnit: "g",
    calories: 165,
    proteinGrams: 31,
    carbGrams: 0,
    fatGrams: 3.6,
    category: FoodItemCategory.protein,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Salmon Fillet",
    brand: "Generic, Cooked",
    servingSizeQuantity: 100,
    servingSizeUnit: "g",
    calories: 208,
    proteinGrams: 20,
    carbGrams: 0,
    fatGrams: 13,
    category: FoodItemCategory.protein,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Egg",
    servingSizeQuantity: 1,
    servingSizeUnit: "large piece", // approx 50g
    calories: 78,
    proteinGrams: 6,
    carbGrams: 0.6,
    fatGrams: 5,
    category: FoodItemCategory.protein,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Tofu",
    brand: "Generic, Firm",
    servingSizeQuantity: 100,
    servingSizeUnit: "g",
    calories: 76,
    proteinGrams: 8,
    carbGrams: 1.9,
    fatGrams: 4.8,
    category: FoodItemCategory.protein,
  ),

  // Grains
  FoodItem(
    id: _uuid.v4(),
    name: "Brown Rice",
    brand: "Generic, Cooked",
    servingSizeQuantity: 100,
    servingSizeUnit: "g", // approx 1/2 cup cooked
    calories: 111,
    proteinGrams: 2.6,
    carbGrams: 23,
    fatGrams: 0.9,
    category: FoodItemCategory.grain,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Whole Wheat Bread",
    servingSizeQuantity: 1,
    servingSizeUnit: "slice", // approx 30g
    calories: 70,
    proteinGrams: 3,
    carbGrams: 12,
    fatGrams: 1,
    category: FoodItemCategory.grain,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Oats",
    brand: "Generic, Dry Rolled",
    servingSizeQuantity: 40, // approx 1/2 cup dry
    servingSizeUnit: "g",
    calories: 150,
    proteinGrams: 5,
    carbGrams: 27,
    fatGrams: 2.5,
    category: FoodItemCategory.grain,
  ),

  // Dairy
  FoodItem(
    id: _uuid.v4(),
    name: "Milk, Whole",
    servingSizeQuantity: 240, // 1 cup
    servingSizeUnit: "ml",
    calories: 150,
    proteinGrams: 8,
    carbGrams: 12,
    fatGrams: 8,
    category: FoodItemCategory.dairy,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Greek Yogurt, Plain",
    servingSizeQuantity: 100,
    servingSizeUnit: "g",
    calories: 59,
    proteinGrams: 10,
    carbGrams: 3.6,
    fatGrams: 0.4,
    category: FoodItemCategory.dairy,
  ),

  // Fats
   FoodItem(
    id: _uuid.v4(),
    name: "Almonds",
    servingSizeQuantity: 28, // approx 1 oz or 23 almonds
    servingSizeUnit: "g",
    calories: 164,
    proteinGrams: 6,
    carbGrams: 6,
    fatGrams: 14,
    category: FoodItemCategory.fat,
  ),
  FoodItem(
    id: _uuid.v4(),
    name: "Avocado",
    servingSizeQuantity: 50, // approx 1/4 medium avocado
    servingSizeUnit: "g",
    calories: 80,
    proteinGrams: 1,
    carbGrams: 4.3,
    fatGrams: 7.3,
    category: FoodItemCategory.fat,
  ),
];

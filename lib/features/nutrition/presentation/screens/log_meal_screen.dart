import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/food_item.dart';
import 'package:aksumfit/models/meal.dart';
import 'package:aksumfit/models/meal_item.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // For date formatting if needed here, or rely on DailyMealLog

const _uuid = Uuid();

class LogMealScreen extends StatefulWidget {
  final DateTime date; // Date for which the meal is being logged
  final MealType? initialMealType; // Optional: pre-select meal type

  const LogMealScreen({super.key, required this.date, this.initialMealType});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  MealType _selectedMealType = MealType.breakfast;
  List<MealItem> _currentMealItems = [];
  List<FoodItem> _searchResults = [];
  bool _isLoadingFood = false;
  bool _isSavingMeal = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customFoodNameController = TextEditingController();
  final TextEditingController _customCaloriesController = TextEditingController();
  final TextEditingController _customProteinController = TextEditingController();
  final TextEditingController _customCarbsController = TextEditingController();
  final TextEditingController _customFatController = TextEditingController();
  final TextEditingController _customServingSizeQtyController = TextEditingController(text: "100");
  final TextEditingController _customServingSizeUnitController = TextEditingController(text: "g");


  @override
  void initState() {
    super.initState();
    if (widget.initialMealType != null) {
      _selectedMealType = widget.initialMealType!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customFoodNameController.dispose();
    _customCaloriesController.dispose();
    _customProteinController.dispose();
    _customCarbsController.dispose();
    _customFatController.dispose();
    _customServingSizeQtyController.dispose();
    _customServingSizeUnitController.dispose();
    super.dispose();
  }

  Future<void> _searchFood() async {
    if (_searchController.text.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isLoadingFood = true;
    });
    try {
      final results = await ApiService().searchFoodItems(_searchController.text);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching food: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoadingFood = false;
      });
    }
  }

  void _addFoodItemToMeal(FoodItem foodItem, double quantity, String unit) {
    // Basic validation for quantity
    if (quantity <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity.")),
      );
      return;
    }

    final mealItem = MealItem(
      baseFoodItem: foodItem,
      loggedQuantity: quantity,
      loggedUnit: unit.isNotEmpty ? unit : foodItem.servingSizeUnit, // Default to food's serving unit if input is empty
    );
    setState(() {
      _currentMealItems.add(mealItem);
      _searchResults = []; // Clear search results after adding
      _searchController.clear();
    });
  }

  void _showAddFoodItemDialog(FoodItem foodItem) {
    final quantityController = TextEditingController(text: foodItem.servingSizeQuantity.toString());
    // Default unit could be the foodItem's serving unit, or a common one like 'g'
    final unitController = TextEditingController(text: foodItem.servingSizeUnit);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add ${foodItem.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Serving: ${foodItem.servingSizeDisplay}"),
            const SizedBox(height: 10),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Quantity"),
              autofocus: true,
            ),
            TextField(
              controller: unitController,
              decoration: InputDecoration(labelText: "Unit (e.g., ${foodItem.servingSizeUnit}, g, piece)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text) ?? 0;
              _addFoodItemToMeal(foodItem, quantity, unitController.text);
              Navigator.of(context).pop();
            },
            child: const Text("Add to Meal"),
          ),
        ],
      ),
    );
  }

  void _showAddCustomFoodDialog() {
    // Clear controllers for new entry
    _customFoodNameController.clear();
    _customCaloriesController.clear();
    _customProteinController.clear();
    _customCarbsController.clear();
    _customFatController.clear();
    _customServingSizeQtyController.text = "100"; // Default
    _customServingSizeUnitController.text = "g"; // Default

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Custom Food"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _customFoodNameController, decoration: const InputDecoration(labelText: "Food Name*")),
                TextField(controller: _customCaloriesController, decoration: const InputDecoration(labelText: "Calories*", hintText: "per serving"), keyboardType: TextInputType.number),
                TextField(controller: _customProteinController, decoration: const InputDecoration(labelText: "Protein (g)*", hintText: "per serving"), keyboardType: TextInputType.number),
                TextField(controller: _customCarbsController, decoration: const InputDecoration(labelText: "Carbs (g)*", hintText: "per serving"), keyboardType: TextInputType.number),
                TextField(controller: _customFatController, decoration: const InputDecoration(labelText: "Fat (g)*", hintText: "per serving"), keyboardType: TextInputType.number),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _customServingSizeQtyController, decoration: const InputDecoration(labelText: "Serving Qty*"), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _customServingSizeUnitController, decoration: const InputDecoration(labelText: "Serving Unit*"))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                // Validation
                if (_customFoodNameController.text.isEmpty ||
                    _customCaloriesController.text.isEmpty ||
                    _customProteinController.text.isEmpty ||
                    _customCarbsController.text.isEmpty ||
                    _customFatController.text.isEmpty ||
                    _customServingSizeQtyController.text.isEmpty ||
                    _customServingSizeUnitController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required (*) fields.")));
                  return;
                }

                final customFood = FoodItem(
                  id: _uuid.v4(), // Generate unique ID
                  name: _customFoodNameController.text,
                  calories: double.tryParse(_customCaloriesController.text) ?? 0,
                  proteinGrams: double.tryParse(_customProteinController.text) ?? 0,
                  carbGrams: double.tryParse(_customCarbsController.text) ?? 0,
                  fatGrams: double.tryParse(_customFatController.text) ?? 0,
                  servingSizeQuantity: double.tryParse(_customServingSizeQtyController.text) ?? 1,
                  servingSizeUnit: _customServingSizeUnitController.text,
                  isCustom: true, // Mark as custom
                );
                // Directly add this custom food as a meal item with quantity 1 of its defined serving
                _addFoodItemToMeal(customFood, customFood.servingSizeQuantity, customFood.servingSizeUnit);
                Navigator.of(context).pop();
              },
              child: const Text("Add Custom Food"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _saveMeal() async {
    if (_currentMealItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one food item to the meal.")),
      );
      return;
    }
    setState(() => _isSavingMeal = true);

    final authManager = Provider.of<AuthManager>(context, listen: false);
    final userId = authManager.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      setState(() => _isSavingMeal = false);
      return;
    }

    try {
      DailyMealLog? dailyLog = await ApiService().getDailyMealLog(userId, widget.date);

      final newMeal = Meal(
        type: _selectedMealType,
        items: _currentMealItems,
        loggedAt: DateTime.now(), // Use current time for logging, date is widget.date
      );

      if (dailyLog == null) {
        dailyLog = DailyMealLog(userId: userId, date: widget.date, meals: [newMeal]);
      } else {
        // Check if a meal of the same type already exists for this day
        final existingMealIndex = dailyLog.meals.indexWhere((m) => m.type == _selectedMealType);
        if (existingMealIndex != -1) {
          // Append items to existing meal or replace? For now, let's append.
          // A more robust UX might ask the user or have separate "add to existing" vs "new"
          final updatedMeal = dailyLog.meals[existingMealIndex].copyWith(
            items: [...dailyLog.meals[existingMealIndex].items, ..._currentMealItems]
          );
           dailyLog.meals[existingMealIndex] = updatedMeal; // This won't recalculate totals in Meal if not careful
           // Re-create the meal list to ensure DailyMealLog recalculates totals
           dailyLog = dailyLog.copyWith(meals: List.from(dailyLog.meals));


        } else {
          dailyLog.meals.add(newMeal);
           dailyLog = dailyLog.copyWith(meals: List.from(dailyLog.meals)); // Recalculate totals
        }
      }

      await ApiService().saveDailyMealLog(dailyLog);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${_selectedMealType.toString().split('.').last.capitalize()} logged successfully!")),
      );
      if (mounted) Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving meal: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSavingMeal = false);
    }
  }

  // Helper to calculate current meal totals
  double get _currentMealTotalCalories => _currentMealItems.fold(0, (sum, item) => sum + item.caloriesConsumed);
  double get _currentMealTotalProtein => _currentMealItems.fold(0, (sum, item) => sum + item.proteinConsumedGrams);
  double get _currentMealTotalCarbs => _currentMealItems.fold(0, (sum, item) => sum + item.carbConsumedGrams);
  double get _currentMealTotalFat => _currentMealItems.fold(0, (sum, item) => sum + item.fatConsumedGrams);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Log Meal for ${DateFormat.yMd().format(widget.date)}", style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: _isSavingMeal ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)) : const Icon(Icons.check),
            onPressed: _isSavingMeal ? null : _saveMeal,
            tooltip: "Save Meal",
          )
        ],
      ),
      body: Column(
        children: [
          // Meal Type Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<MealType>(
              segments: MealType.values.map((type) => ButtonSegment(
                value: type,
                label: Text(type.toString().split('.').last.capitalize()),
                icon: Icon(_getMealTypeIcon(type)),
              )).toList(),
              selected: {_selectedMealType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedMealType = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: theme.colorScheme.primaryContainer,
                selectedForegroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search food items...",
                      prefixIcon: const Icon(CupertinoIcons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(icon: const Icon(CupertinoIcons.clear_circled_solid), onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            })
                          : null,
                    ),
                    onChanged: (value) => _searchFood(), // Debounce this in a real app
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.plus_circle_fill),
                  tooltip: "Add Custom Food",
                  color: theme.colorScheme.secondary,
                  iconSize: 30,
                  onPressed: _showAddCustomFoodDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search Results / Loading
          if (_isLoadingFood)
            const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()))
          else if (_searchResults.isNotEmpty)
            Expanded(
              flex: 2, // Give search results some space, but not too much initially
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final foodItem = _searchResults[index];
                  return ListTile(
                    title: Text(foodItem.name),
                    subtitle: Text("${foodItem.brand.isNotEmpty ? foodItem.brand : ''} - ${foodItem.calories.toStringAsFixed(0)} kcal per ${foodItem.servingSizeDisplay}"),
                    onTap: () => _showAddFoodItemDialog(foodItem),
                  );
                },
              ),
            ),

          // Current Meal Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Current Meal Items (${_currentMealItems.length})", style: theme.textTheme.titleLarge),
          ),
          Expanded(
            flex: 3, // Give more space to the meal items list
            child: _currentMealItems.isEmpty
                ? Center(child: Text("No items added to this meal yet.", style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant)))
                : ListView.builder(
                    itemCount: _currentMealItems.length,
                    itemBuilder: (context, index) {
                      final item = _currentMealItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(item.baseFoodItem.name),
                          subtitle: Text("${item.loggedQuantity.toStringAsFixed(1)} ${item.loggedUnit} - ${item.caloriesConsumed.toStringAsFixed(0)} kcal (P:${item.proteinConsumedGrams.toStringAsFixed(0)}g C:${item.carbConsumedGrams.toStringAsFixed(0)}g F:${item.fatConsumedGrams.toStringAsFixed(0)}g)"),
                          trailing: IconButton(
                            icon: const Icon(CupertinoIcons.minus_circle, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _currentMealItems.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
           // Meal Totals Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Meal Totals:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Calories: ${_currentMealTotalCalories.toStringAsFixed(0)} kcal"),
                    Text("Protein: ${_currentMealTotalProtein.toStringAsFixed(1)} g"),
                    Text("Carbs: ${_currentMealTotalCarbs.toStringAsFixed(1)} g"),
                    Text("Fat: ${_currentMealTotalFat.toStringAsFixed(1)} g"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast: return CupertinoIcons.sunrise_fill; // Example
      case MealType.lunch: return CupertinoIcons.sun_max_fill; // Example
      case MealType.dinner: return CupertinoIcons.moon_stars_fill; // Example
      case MealType.snack: return CupertinoIcons.cube_box_fill; // Example
      default: return CupertinoIcons.square_fill_on_square_fill;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}

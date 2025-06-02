import 'dart:io'; // Import for File
import 'package:aksumfit/models/food_item.dart';
import 'package:aksumfit/models/meal.dart';
import 'package:aksumfit/models/meal_item.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Keep for ScaffoldMessenger, showDialog, AlertDialog
import 'package:aksumfit/core/extensions/string_extensions.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const _uuid = Uuid();

class LogMealScreen extends StatefulWidget {
  final DateTime date;
  final MealType? initialMealType;
  final String? imagePath;

  const LogMealScreen({
    super.key,
    required this.date,
    this.initialMealType,
    this.imagePath,
  });

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  MealType _selectedMealType = MealType.breakfast;
  final List<MealItem> _currentMealItems = [];
  List<FoodItem> _searchResults = [];
  String? _capturedImagePath;
  bool _isLoadingFood = false;
  final bool _isSavingMeal = false;

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
    _capturedImagePath = widget.imagePath;
    // If an image path is provided, you might want to trigger an action,
    // like pre-filling search or showing AI suggestions (future enhancement).
    if (_capturedImagePath != null) {
        print("LogMealScreen received imagePath: $_capturedImagePath");
        // Placeholder: Show a snackbar if image is received
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Image received: ${_capturedImagePath!.split('/').last}"))
                );
            }
        });
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
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoadingFood = true);
    try {
      final results = await ApiService().searchFoodItems(_searchController.text);
      setState(() => _searchResults = results);
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error searching food: ${e.toString()}")));
    } finally {
      if(mounted) setState(() => _isLoadingFood = false);
    }
  }

  void _addFoodItemToMeal(FoodItem foodItem, double quantity, String unit) {
    if (quantity <= 0) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid quantity.")));
      return;
    }
    final mealItem = MealItem(
      baseFoodItem: foodItem,
      loggedQuantity: quantity,
      loggedUnit: unit.isNotEmpty ? unit : foodItem.servingSizeUnit,
    );
    setState(() {
      _currentMealItems.add(mealItem);
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _showAddFoodItemDialog(FoodItem foodItem) {
    final quantityController = TextEditingController(text: foodItem.servingSizeQuantity.toString());
    final unitController = TextEditingController(text: foodItem.servingSizeUnit);
    showDialog( // Using Material AlertDialog for now, can be CupertinoAlertDialog
      context: context,
      builder: (context) => AlertDialog( // Or CupertinoAlertDialog
        title: Text("Add ${foodItem.name}"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Serving: ${foodItem.servingSizeDisplay}"),
          const SizedBox(height: 10),
          TextField(controller: quantityController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: "Quantity"), autofocus: true),
          TextField(controller: unitController, decoration: InputDecoration(labelText: "Unit (e.g., ${foodItem.servingSizeUnit}, g, piece)")),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(onPressed: () {
            final quantity = double.tryParse(quantityController.text) ?? 0;
            _addFoodItemToMeal(foodItem, quantity, unitController.text);
            Navigator.of(context).pop();
          }, child: const Text("Add to Meal")),
        ],
      ),
    );
  }

  void _showAddCustomFoodDialog() {
    _customFoodNameController.clear(); _customCaloriesController.clear(); _customProteinController.clear();
    _customCarbsController.clear(); _customFatController.clear();
    _customServingSizeQtyController.text = "100"; _customServingSizeUnitController.text = "g";
    showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text("Add Custom Food"),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _customFoodNameController, decoration: const InputDecoration(labelText: "Food Name*")),
            TextField(controller: _customCaloriesController, decoration: const InputDecoration(labelText: "Calories*", hintText: "per serving"), keyboardType: TextInputType.number),
            TextField(controller: _customProteinController, decoration: const InputDecoration(labelText: "Protein (g)*", hintText: "per serving"), keyboardType: TextInputType.number),
            TextField(controller: _customCarbsController, decoration: const InputDecoration(labelText: "Carbs (g)*", hintText: "per serving"), keyboardType: TextInputType.number),
            TextField(controller: _customFatController, decoration: const InputDecoration(labelText: "Fat (g)*", hintText: "per serving"), keyboardType: TextInputType.number),
            Row(children: [
                Expanded(child: TextField(controller: _customServingSizeQtyController, decoration: const InputDecoration(labelText: "Serving Qty*"), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _customServingSizeUnitController, decoration: const InputDecoration(labelText: "Serving Unit*"))),
            ]),
        ])),
        actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            TextButton(onPressed: () {
                if (_customFoodNameController.text.isEmpty || _customCaloriesController.text.isEmpty || _customProteinController.text.isEmpty ||
                    _customCarbsController.text.isEmpty || _customFatController.text.isEmpty || _customServingSizeQtyController.text.isEmpty ||
                    _customServingSizeUnitController.text.isEmpty) {
                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required (*) fields.")));
                    return;
                }
                final customFood = FoodItem(id: _uuid.v4(), name: _customFoodNameController.text, calories: double.tryParse(_customCaloriesController.text) ?? 0,
                    proteinGrams: double.tryParse(_customProteinController.text) ?? 0, carbGrams: double.tryParse(_customCarbsController.text) ?? 0,
                    fatGrams: double.tryParse(_customFatController.text) ?? 0, servingSizeQuantity: double.tryParse(_customServingSizeQtyController.text) ?? 1,
                    servingSizeUnit: _customServingSizeUnitController.text, isCustom: true);
                _addFoodItemToMeal(customFood, customFood.servingSizeQuantity, customFood.servingSizeUnit);
                Navigator.of(context).pop();
            }, child: const Text("Add Custom Food")),
        ],
    ));
  }

  Future<void> _saveMeal() async { /* ... existing _saveMeal logic ... */ }
  double get _currentMealTotalCalories => _currentMealItems.fold(0, (sum, item) => sum + item.caloriesConsumed);
  double get _currentMealTotalProtein => _currentMealItems.fold(0, (sum, item) => sum + item.proteinConsumedGrams);
  double get _currentMealTotalCarbs => _currentMealItems.fold(0, (sum, item) => sum + item.carbConsumedGrams);
  double get _currentMealTotalFat => _currentMealItems.fold(0, (sum, item) => sum + item.fatConsumedGrams);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Log ${DateFormat.yMd().format(widget.date)} Meal"),
        trailing: CupertinoButton(padding: EdgeInsets.zero, onPressed: _isSavingMeal ? null : _saveMeal,
            child: _isSavingMeal ? const CupertinoActivityIndicator() : const Text("Save")),
      ),
      child: SafeArea( // Ensure content is within safe area
        child: Column(
          children: [
            Padding( // Meal Type Selector
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: CupertinoSlidingSegmentedControl<MealType>(
                children: { for (var type in MealType.values) type: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [ Icon(_getMealTypeIcon(type), size: 18),
                            const SizedBox(width: 6), Text(type.toString().split('.').last.capitalize())]))},
                groupValue: _selectedMealType,
                onValueChanged: (newSelection) { if (newSelection != null) setState(() => _selectedMealType = newSelection);},
              ),
            ),

            if (_capturedImagePath != null && _capturedImagePath!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect( // To round corners of the image
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        File(_capturedImagePath!),
                        height: 200, // Fixed height
                        width: double.infinity, // Full width
                        fit: BoxFit.cover,
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(4.0),
                      onPressed: () => setState(() => _capturedImagePath = null),
                      child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.white, size: 28),
                    )
                  ],
                ),
              ),

            Padding( // Search Bar & Add Custom Button
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0), // Adjusted padding
              child: Row(children: [
                  Expanded(child: CupertinoSearchTextField(controller: _searchController, placeholder: "Search food items...",
                      onChanged: (value) => _searchFood(), onSuffixTap: () { _searchController.clear(); setState(() => _searchResults = []);},)),
                  CupertinoButton(padding: const EdgeInsets.only(left: 8.0), onPressed: _showAddCustomFoodDialog,
                      child: const Icon(CupertinoIcons.plus_circle_fill, size: 32)), // Slightly larger icon
              ]),
            ),

            if (_isLoadingFood) const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CupertinoActivityIndicator()))
            else if (_searchResults.isNotEmpty)
              Expanded(flex: 2, child: CupertinoListSection.insetGrouped( // Using ListSection for search results
                header: const Text("Search Results"),
                children: _searchResults.map((foodItem) => CupertinoListTile(
                    title: Text(foodItem.name),
                    subtitle: Text("${foodItem.brand.isNotEmpty ? foodItem.brand : ''} - ${foodItem.calories.toStringAsFixed(0)} kcal per ${foodItem.servingSizeDisplay}"),
                    onTap: () => _showAddFoodItemDialog(foodItem),
                    )).toList(),
                )),

            CupertinoListSection.insetGrouped( // Current meal items
              header: Text("Current Meal Items (${_currentMealItems.length})", style: cupertinoTheme.textTheme.textStyle), // Using textStyle for section header
              children: _currentMealItems.isEmpty
                  ? [const CupertinoListTile(title: Center(child: Text("No items added yet.")))]
                  : _currentMealItems.map((item) => CupertinoListTile.notched(
                        title: Text(item.baseFoodItem.name),
                        subtitle: Text("${item.loggedQuantity.toStringAsFixed(1)} ${item.loggedUnit} - ${item.caloriesConsumed.toStringAsFixed(0)} kcal (P:${item.proteinConsumedGrams.toStringAsFixed(0)}g C:${item.carbConsumedGrams.toStringAsFixed(0)}g F:${item.fatConsumedGrams.toStringAsFixed(0)}g)"),
                        trailing: CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.minus_circle, color: CupertinoColors.destructiveRed),
                            onPressed: () => setState(() => _currentMealItems.remove(item))), // Use remove(item)
                      )).toList(),
            ),

            Expanded( // Use Expanded for the totals section to push it down if there's space, or scroll if not
              child: SingleChildScrollView( // Ensure totals are scrollable if content above is large
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0), // Add some space above totals
                  child: CupertinoListSection.insetGrouped(
                    header: Text("Meal Totals", style: cupertinoTheme.textTheme.textStyle),
                    children: [
                      CupertinoListTile(title: const Text("Calories"), additionalInfo: Text("${_currentMealTotalCalories.toStringAsFixed(0)} kcal")),
                      CupertinoListTile(title: const Text("Protein"), additionalInfo: Text("${_currentMealTotalProtein.toStringAsFixed(1)} g")),
                      CupertinoListTile(title: const Text("Carbs"), additionalInfo: Text("${_currentMealTotalCarbs.toStringAsFixed(1)} g")),
                      CupertinoListTile(title: const Text("Fat"), additionalInfo: Text("${_currentMealTotalFat.toStringAsFixed(1)} g")),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast: return CupertinoIcons.sunrise_fill;
      case MealType.lunch: return CupertinoIcons.sun_max_fill;
      case MealType.dinner: return CupertinoIcons.moon_stars_fill;
      case MealType.snack: return CupertinoIcons.cube_box_fill;
      default: return CupertinoIcons.square_fill_on_square_fill;
    }
  }
}

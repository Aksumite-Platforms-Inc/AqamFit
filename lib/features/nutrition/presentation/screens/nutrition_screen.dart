// Removed duplicate imports
import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/meal.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/features/nutrition/presentation/screens/log_meal_screen.dart';
import 'package:aksumfit/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart'; // Changed from Cupertino
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();
  Future<DailyMealLog?>? _dailyLogFuture;
  String? _userId;

  // TODO: Add user's daily targets (calories, macros) - fetched from user profile/settings
  final double _targetCalories = 2500;
  final double _targetProtein = 150; // grams
  final double _targetCarbs = 300; // grams
  final double _targetFat = 70; // grams

  @override
  void initState() {
    super.initState();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.currentUser?.id;
    if (_userId != null) {
      _loadDailyLogForDate(_selectedDate);
    }
  }

  void _loadDailyLogForDate(DateTime date) {
    if (_userId == null) return;
    setState(() {
      _selectedDate = date;
      _dailyLogFuture = ApiService().getDailyMealLog(_userId!, date);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      _loadDailyLogForDate(picked);
    }
  }

  Future<void> _logMealForType(MealType mealType) async {
    if (_userId == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LogMealScreen(date: _selectedDate, initialMealType: mealType),
      ),
    );
    if (result == true && mounted) {
      _loadDailyLogForDate(_selectedDate);
    }
  }

  void _showAddMealActionSheet() async {
    MealType? selectedType = await showModalBottomSheet<MealType>( // Changed to showModalBottomSheet
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: MealType.values
                .map((type) => ListTile(
                      leading: Icon(_getMealTypeIcon(type, Theme.of(context))), // Pass theme for icon color
                      title: Text(type.toString().split('.').last.capitalize()),
                      onTap: () => Navigator.of(context).pop(type),
                    ))
                .toList(),
          ),
        );
      },
    );
    if (selectedType != null) {
      _logMealForType(selectedType);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get Material theme

    return Scaffold( // Changed to Scaffold
      appBar: AppBar( // Changed to AppBar
        title: const Text('Nutrition Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddMealActionSheet, // Call the new method
          ),
        ],
      ),
      body: _userId == null
          ? Center(child: Text("Please login to view nutrition data.", style: theme.textTheme.titleMedium))
          : RefreshIndicator( // Added RefreshIndicator
              onRefresh: () async => _loadDailyLogForDate(_selectedDate),
              child: ListView( // Changed CustomScrollView to ListView for simplicity with these elements
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildDateHeaderMaterial(theme),
                  const SizedBox(height: 20),
                  FutureBuilder<DailyMealLog?>(
                    future: _dailyLogFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator()); // Changed to CircularProgressIndicator
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text("Error: ${snapshot.error}",
                                style: TextStyle(color: theme.colorScheme.error)));
                      }

                      final dailyLog = snapshot.data;
                      return Column(
                        children: [
                          _buildSummaryCardMaterial(theme, dailyLog),
                          const SizedBox(height: 24),
                          _buildMealsSectionMaterial(theme, dailyLog),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateHeaderMaterial(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween for better layout
        children: [
          IconButton( // Changed to IconButton
            icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary, size: 32),
            onPressed: () => _loadDailyLogForDate(_selectedDate.subtract(const Duration(days: 1))),
          ),
          TextButton( // Changed to TextButton for date display
            onPressed: () => _selectDate(context),
            child: Text(
              DateFormat.yMMMMd().format(_selectedDate),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton( // Changed to IconButton
            icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary, size: 32),
            onPressed: () => _loadDailyLogForDate(_selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardMaterial(ThemeData theme, DailyMealLog? dailyLog) {
    final currentCalories = dailyLog?.dailyTotalCalories ?? 0;
    final currentProtein = dailyLog?.dailyTotalProteinGrams ?? 0;
    final currentCarbs = dailyLog?.dailyTotalCarbGrams ?? 0;
    final currentFat = dailyLog?.dailyTotalFatGrams ?? 0;

    return Card( // Changed to Card
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Summary", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMacroProgressMaterial("Calories", currentCalories, _targetCalories, "kcal", theme.colorScheme.primary, theme),
            const SizedBox(height: 12),
            _buildMacroProgressMaterial("Protein", currentProtein, _targetProtein, "g", Colors.green, theme),
            const SizedBox(height: 12),
            _buildMacroProgressMaterial("Carbs", currentCarbs, _targetCarbs, "g", Colors.orange, theme),
            const SizedBox(height: 12),
            _buildMacroProgressMaterial("Fat", currentFat, _targetFat, "g", Colors.purple, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroProgressMaterial(String label, double current, double target, String unit, Color progressColor, ThemeData theme) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$label: ${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit", style: theme.textTheme.titleMedium),
            Text("${(progress * 100).toStringAsFixed(0)}%", style: theme.textTheme.titleSmall?.copyWith(color: progressColor)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: progressColor.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMealsSectionMaterial(ThemeData theme, DailyMealLog? dailyLog) {
    final meals = dailyLog?.meals ?? [];
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.no_food_outlined, size: 60, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 10),
              Text("No meals logged for this day yet.", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Column( // Main column for all meal cards
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
           padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
           child: Text("Logged Meals", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
         ),
        ...meals.map((meal) { // Spread the generated cards into the Column
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile( // Use ExpansionTile for each meal type
              leading: Icon(_getMealTypeIcon(meal.type, theme), color: theme.colorScheme.primary, size: 28),
              title: Text(
                "${meal.type.toString().split('.').last.capitalize()} - ${meal.totalCalories.toStringAsFixed(0)} kcal",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "P: ${meal.totalProteinGrams.toStringAsFixed(0)}g, C: ${meal.totalCarbGrams.toStringAsFixed(0)}g, F: ${meal.totalFatGrams.toStringAsFixed(0)}g",
                style: theme.textTheme.bodyMedium,
              ),
              children: meal.items.map((item) => ListTile(
                dense: true,
                title: Text(item.baseFoodItem.name, style: theme.textTheme.bodyMedium),
                trailing: Text("${item.caloriesConsumed.toStringAsFixed(0)} kcal", style: theme.textTheme.bodySmall),
                // TODO: Add onTap for editing/deleting a meal item if needed
              )).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }

  IconData _getMealTypeIcon(MealType type, ThemeData theme) { // Pass theme for consistency if needed
    switch (type) {
      case MealType.breakfast: return Icons.free_breakfast_outlined;
      case MealType.lunch: return Icons.lunch_dining_outlined;
      case MealType.dinner: return Icons.dinner_dining_outlined;
      case MealType.snack: return Icons.bakery_dining_outlined; // Or Icons.icecream_outlined etc.
      default: return Icons.restaurant_outlined;
    }
  }
}

import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/meal.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/features/nutrition/presentation/screens/log_meal_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      _selectedDate = date; // Ensure _selectedDate is updated for the UI
      _dailyLogFuture = ApiService().getDailyMealLog(_userId!, date);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow future logging for planning
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
      _loadDailyLogForDate(_selectedDate); // Refresh data if a meal was logged
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Dashboard', style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.calendar),
            onPressed: () => _selectDate(context),
            tooltip: "Select Date",
          ),
        ],
      ),
      body: _userId == null
          ? const Center(child: Text("Please login to view nutrition data."))
          : RefreshIndicator(
            onRefresh: () async => _loadDailyLogForDate(_selectedDate),
            child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildDateHeader(theme, textTheme),
                  const SizedBox(height: 20),
                  FutureBuilder<DailyMealLog?>(
                    future: _dailyLogFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: theme.colorScheme.error)));
                      }

                      final dailyLog = snapshot.data;
                      return Column(
                        children: [
                          _buildSummaryCard(theme, textTheme, dailyLog),
                          const SizedBox(height: 24),
                          _buildMealsSection(theme, textTheme, dailyLog),
                        ],
                      );
                    },
                  ),
                ],
              ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
           // Show a dialog to pick meal type then navigate
           MealType? selectedType = await showCupertinoModalPopup<MealType>(
             context: context,
             builder: (BuildContext context) => CupertinoActionSheet(
               title: const Text('Which meal to log?'),
               actions: MealType.values.map((type) => CupertinoActionSheetAction(
                 child: Text(type.toString().split('.').last.capitalize()),
                 onPressed: () => Navigator.of(context).pop(type),
               )).toList(),
               cancelButton: CupertinoActionSheetAction(
                 child: const Text('Cancel'),
                 onPressed: () => Navigator.of(context).pop(),
               ),
             ),
           );
           if (selectedType != null) {
             _logMealForType(selectedType);
           }
        },
        label: const Text("Log Meal"),
        icon: const Icon(CupertinoIcons.add_circled_solid),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        foregroundColor: theme.colorScheme.onTertiaryContainer,
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(CupertinoIcons.chevron_left_circle_fill, color: theme.colorScheme.primary, size: 28),
          onPressed: () => _loadDailyLogForDate(_selectedDate.subtract(const Duration(days: 1))),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Text(
            DateFormat.yMMMMd().format(_selectedDate), // e.g., "July 10, 2023"
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(CupertinoIcons.chevron_right_circle_fill, color: theme.colorScheme.primary, size: 28),
          onPressed: () => _loadDailyLogForDate(_selectedDate.add(const Duration(days: 1))),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme, TextTheme textTheme, DailyMealLog? dailyLog) {
    final currentCalories = dailyLog?.dailyTotalCalories ?? 0;
    final currentProtein = dailyLog?.dailyTotalProteinGrams ?? 0;
    final currentCarbs = dailyLog?.dailyTotalCarbGrams ?? 0;
    final currentFat = dailyLog?.dailyTotalFatGrams ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Summary", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildMacroProgress("Calories", currentCalories, _targetCalories, "kcal", theme.colorScheme.primary),
            _buildMacroProgress("Protein", currentProtein, _targetProtein, "g", Colors.green.shade600),
            _buildMacroProgress("Carbs", currentCarbs, _targetCarbs, "g", Colors.orange.shade600),
            _buildMacroProgress("Fat", currentFat, _targetFat, "g", Colors.purple.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroProgress(String label, double current, double target, String unit, Color progressColor) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$label: ${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit", style: GoogleFonts.inter()),
              Text("${(progress * 100).toStringAsFixed(0)}%"),
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
      ),
    );
  }

  Widget _buildMealsSection(ThemeData theme, TextTheme textTheme, DailyMealLog? dailyLog) {
    final meals = dailyLog?.meals ?? [];
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: Column(
            children: [
              Icon(CupertinoIcons.square_stack_3d_down_dottedline, size: 60, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height:10),
              Text("No meals logged for this day yet.", style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Logged Meals", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ExpansionTile(
                leading: Icon(_getMealTypeIcon(meal.type), color: theme.colorScheme.primary, size: 28),
                title: Text(
                  "${meal.type.toString().split('.').last.capitalize()} - ${meal.totalCalories.toStringAsFixed(0)} kcal",
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "P: ${meal.totalProteinGrams.toStringAsFixed(0)}g, C: ${meal.totalCarbGrams.toStringAsFixed(0)}g, F: ${meal.totalFatGrams.toStringAsFixed(0)}g",
                   style: textTheme.bodySmall,
                ),
                children: meal.items.map((item) => ListTile(
                  title: Text(item.baseFoodItem.name, style: textTheme.bodyMedium),
                  subtitle: Text("${item.loggedQuantity.toStringAsFixed(1)} ${item.loggedUnit}", style: textTheme.bodySmall),
                  trailing: Text("${item.caloriesConsumed.toStringAsFixed(0)} kcal", style: textTheme.bodyMedium),
                  dense: true,
                )).toList(),
                // TODO: Add an "Add to this meal" or "Edit meal" button?
              ),
            );
          },
        ),
      ],
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

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}

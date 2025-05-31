import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/meal.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/features/nutrition/presentation/screens/log_meal_screen.dart';
import 'package:aksumfit/core/extensions/string_extensions.dart';

import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/meal.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/features/nutrition/presentation/screens/log_meal_screen.dart';
import 'package:aksumfit/core/extensions/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Keep for LinearProgressIndicator, showDatePicker
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
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Nutrition Dashboard'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add_circled),
          onPressed: () async {
            MealType? selectedType = await showCupertinoModalPopup<MealType>(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                title: const Text('Which meal to log?'),
                actions: MealType.values
                    .map((type) => CupertinoActionSheetAction(
                          child: Text(type.toString().split('.').last.capitalize()),
                          onPressed: () => Navigator.of(context).pop(type),
                        ))
                    .toList(),
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
        ),
      ),
      child: _userId == null
          ? const Center(child: Text("Please login to view nutrition data."))
          : CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                    onRefresh: () async => _loadDailyLogForDate(_selectedDate)),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildDateHeaderCupertino(cupertinoTheme),
                      const SizedBox(height: 20),
                      FutureBuilder<DailyMealLog?>(
                        future: _dailyLogFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CupertinoActivityIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}",
                                    style: const TextStyle(
                                        color: CupertinoColors.destructiveRed)));
                          }

                          final dailyLog = snapshot.data;
                          return Column(
                            children: [
                              _buildSummaryCardCupertino(
                                  cupertinoTheme, dailyLog),
                              const SizedBox(height: 24),
                              _buildMealsSectionCupertino(
                                  cupertinoTheme, dailyLog),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDateHeaderCupertino(CupertinoThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.chevron_left_circle_fill,
                color: theme.primaryColor, size: 28),
            onPressed: () =>
                _loadDailyLogForDate(_selectedDate.subtract(const Duration(days: 1))),
          ),
          GestureDetector(
            onTap: () => _showDatePicker(context), // Changed to show CupertinoDatePicker
            child: Text(
              DateFormat.yMMMMd().format(_selectedDate),
              style: theme.textTheme.navTitleTextStyle
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.chevron_right_circle_fill,
                color: theme.primaryColor, size: 28),
            onPressed: () =>
                _loadDailyLogForDate(_selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250, // Adjust height as needed
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                       Navigator.of(context).pop();
                      _loadDailyLogForDate(_selectedDate); // Use the potentially updated _selectedDate
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime(2020),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() => _selectedDate = newDate); // Update _selectedDate as user scrolls
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryCardCupertino(CupertinoThemeData theme, DailyMealLog? dailyLog) {
    final currentCalories = dailyLog?.dailyTotalCalories ?? 0;
    final currentProtein = dailyLog?.dailyTotalProteinGrams ?? 0;
    final currentCarbs = dailyLog?.dailyTotalCarbGrams ?? 0;
    final currentFat = dailyLog?.dailyTotalFatGrams ?? 0;

    return CupertinoListSection.insetGrouped(
      header: const Text("Daily Summary"),
      children: [
        _buildMacroProgressCupertino("Calories", currentCalories, _targetCalories, "kcal", theme.primaryColor),
        _buildMacroProgressCupertino("Protein", currentProtein, _targetProtein, "g", CupertinoColors.systemGreen),
        _buildMacroProgressCupertino("Carbs", currentCarbs, _targetCarbs, "g", CupertinoColors.systemOrange),
        _buildMacroProgressCupertino("Fat", currentFat, _targetFat, "g", CupertinoColors.systemPurple),
      ],
    );
  }

  Widget _buildMacroProgressCupertino(String label, double current, double target, String unit, Color progressColor) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final cupertinoTheme = CupertinoTheme.of(context); // Get theme here if needed for text styles

    return CupertinoListTile(
      title: Text("$label: ${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit"),
      subtitle: Padding( // Wrap LinearProgressIndicator in Padding for spacing
        padding: const EdgeInsets.only(top: 4.0),
        child: SizedBox( // Ensure progress bar has a defined height
          height: 8,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: progressColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            // borderRadius: BorderRadius.circular(4), // Not available in Cupertino
          ),
        ),
      ),
      trailing: Text("${(progress * 100).toStringAsFixed(0)}%", style: cupertinoTheme.textTheme.tabLabelTextStyle),
    );
  }


  Widget _buildMealsSectionCupertino(CupertinoThemeData theme, DailyMealLog? dailyLog) {
    final meals = dailyLog?.meals ?? [];
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: Column(
            children: [
              Icon(CupertinoIcons.square_stack_3d_down_dottedline, size: 60, color: CupertinoColors.secondaryLabel.withOpacity(0.5)),
              const SizedBox(height: 10),
              Text("No meals logged for this day yet.", style: theme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel)),
            ],
          ),
        ),
      );
    }

    return CupertinoListSection.insetGrouped(
      header: const Text("Logged Meals"),
      children: meals.map((meal) {
        return CupertinoListTile.notched(
           leading: Icon(_getMealTypeIcon(meal.type), color: theme.primaryColor, size: 28),
           title: Text(
            "${meal.type.toString().split('.').last.capitalize()} - ${meal.totalCalories.toStringAsFixed(0)} kcal",
            style: theme.textTheme.navTitleTextStyle,
          ),
          subtitle: Text(
            "P: ${meal.totalProteinGrams.toStringAsFixed(0)}g, C: ${meal.totalCarbGrams.toStringAsFixed(0)}g, F: ${meal.totalFatGrams.toStringAsFixed(0)}g",
            style: theme.textTheme.tabLabelTextStyle,
          ),
          additionalInfo: Column( // Use additionalInfo to display meal items
            crossAxisAlignment: CrossAxisAlignment.start,
            children: meal.items.map((item) => Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 2.0), // Adjust padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.baseFoodItem.name, style: theme.textTheme.textStyle)),
                  Text("${item.caloriesConsumed.toStringAsFixed(0)} kcal", style: theme.textTheme.tabLabelTextStyle),
                ],
              ),
            )).toList(),
          ),
          // TODO: Add an "Add to this meal" or "Edit meal" button?
        );
      }).toList(),
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

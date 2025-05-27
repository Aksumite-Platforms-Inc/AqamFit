import 'package:flutter/material.dart';

import '../models/meal_entry.dart';
import '../widgets/macro_info_item.dart';
import '../widgets/nutrition_quick_add_button.dart';
import '../widgets/meal_card.dart';

class NutritionScreen extends StatefulWidget {
  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int totalCalories = 1847;
  int targetCalories = 2100;
  double protein = 85.5;
  double carbs = 180.2;
  double fat = 62.8;

  List<MealEntry> todaysMeals = [
    MealEntry('Breakfast', 'Oatmeal with berries', 320, '7:30 AM'),
    MealEntry('Lunch', 'Grilled chicken salad', 450, '12:15 PM'),
    MealEntry('Snack', 'Greek yogurt', 150, '3:00 PM'),
    MealEntry('Dinner', 'Salmon with vegetables', 520, '7:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    double calorieProgress = totalCalories / targetCalories;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              _showAddMealDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Calorie Progress
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF7043), Color(0xFFFFAB40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Daily Calories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: calorieProgress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$totalCalories',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of $targetCalories',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MacroInfoItem(
                        label: 'Protein',
                        value: '${protein.toInt()}g',
                        color: Colors.white,
                      ),
                      MacroInfoItem(
                        label: 'Carbs',
                        value: '${carbs.toInt()}g',
                        color: Colors.white,
                      ),
                      MacroInfoItem(
                          label: 'Fat',
                          value: '${fat.toInt()}g',
                          color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Quick Add Options
            Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NutritionQuickAddButton(
                    title: 'Scan Food',
                    icon: Icons.camera_alt,
                    onTap: () {
                      _showAddMealDialog();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: NutritionQuickAddButton(
                    title: 'Search Food',
                    icon: Icons.search,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Today's Meals
            Text(
              'Today\'s Meals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            ...todaysMeals.map((meal) => MealCard(meal: meal)),
            SizedBox(height: 24),

            // AI Nutrition Insights
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFFFF7043)),
                      SizedBox(width: 8),
                      Text(
                        'AI Nutrition Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You\'re 253 calories under your target. Consider adding a healthy snack with complex carbs. Your protein intake is excellent today!',
                    style: TextStyle(color: Colors.grey[600], height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildMacroInfo removed

  // _buildQuickAddButton removed

  // _buildMealCard removed

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AI Food Scanner'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, size: 64, color: Color(0xFFFF7043)),
              SizedBox(height: 16),
              Text(
                'Point your camera at food to automatically detect and log nutrition information.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Simulate adding a meal
                setState(() {
                  todaysMeals.add(
                    MealEntry(
                      'Snack',
                      'Apple with peanut butter',
                      180,
                      'Just now',
                    ),
                  );
                  totalCalories += 180;
                });
              },
              child: Text('Open Camera'),
            ),
          ],
        );
      },
    );
  }
}

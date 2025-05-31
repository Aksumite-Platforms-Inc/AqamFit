import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/goal.dart';
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/models/weight_entry.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Keep for LinearProgressIndicator
import 'package:go_router/go_router.dart';
import 'package:aksumfit/features/home/widgets/streak_tracker_widget.dart';
import 'package:aksumfit/features/home/widgets/hero_workout_banner.dart';
import 'package:aksumfit/features/home/widgets/quick_action_tile.dart';
import 'package:aksumfit/features/home/widgets/weekly_progress_ring.dart';
import 'package:aksumfit/widgets/activity_feed_item.dart'; // Assuming this is generic enough
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  String _greeting = "";

  // Futures for data
  Future<WorkoutPlan?>? _todaysWorkoutPlanFuture;
  Future<DailyMealLog?>? _dailyMealLogFuture;
  Future<Map<String, int>>? _weeklyStatsFuture;
  Future<WeightEntry?>? _latestWeightFuture;
  Future<List<Goal>>? _activeGoalsFuture;

  // Example target values (would ideally come from user settings or goals)
  final double _targetCalories = 2500;
  final int _targetWeeklyWorkouts = 5;
  final int _targetWeeklyActiveMinutes = 200;


  @override
  void initState() {
    super.initState();
    _greeting = _getGreeting();
    _loadInitialData();
  }

  void _loadInitialData() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _currentUser = authManager.currentUser;
    if (_currentUser != null) {
      final userId = _currentUser!.id;
      setState(() {
        _todaysWorkoutPlanFuture = ApiService().getTodaysWorkoutPlan(userId);
        _dailyMealLogFuture = ApiService().getDailyMealLog(userId, DateTime.now());
        _weeklyStatsFuture = ApiService().getWeeklyWorkoutStats(userId);
        _latestWeightFuture = ApiService().getLatestWeightEntry(userId);
        _activeGoalsFuture = ApiService().getGoals(userId, isActive: true);
      });
    }
  }

  Future<void> _refreshData() async {
     // Potentially re-fetch user if details can change elsewhere and AuthManager doesn't notify
    final authManager = Provider.of<AuthManager>(context, listen: false);
    setState(() {
      _currentUser = authManager.currentUser; // Refresh current user
    });
    if (_currentUser != null) {
      final userId = _currentUser!.id;
       setState(() { // Use setState to ensure UI rebuilds with new futures
        _todaysWorkoutPlanFuture = ApiService().getTodaysWorkoutPlan(userId);
        _dailyMealLogFuture = ApiService().getDailyMealLog(userId, DateTime.now());
        _weeklyStatsFuture = ApiService().getWeeklyWorkoutStats(userId);
        _latestWeightFuture = ApiService().getLatestWeightEntry(userId);
        _activeGoalsFuture = ApiService().getGoals(userId, isActive: true);
      });
    }
  }


  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final userName = _currentUser?.name ?? "User";

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("$_greeting, $userName!"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.bell),
          onPressed: () => context.go('/notifications'),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: _refreshData),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FutureBuilder<WorkoutPlan?>(
                          future: _todaysWorkoutPlanFuture,
                          builder: (context, snapshot) {
                            return HeroWorkoutBanner(
                                workoutPlan: snapshot.data);
                          }),
                      const SizedBox(height: 24),
                      StreakTrackerWidget(
                          streakCount: _currentUser?.streakCount ?? 0),
                      const SizedBox(height: 24),
                      _buildNutritionSummaryCard(cupertinoTheme),
                      const SizedBox(height: 24),
                      _buildWeeklyProgressRings(cupertinoTheme),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildProgressHighlights(cupertinoTheme),
                      const SizedBox(height: 24),
                      _buildAiRecommendationsPlaceholder(cupertinoTheme),
                      const SizedBox(height: 24),
                      _buildRecentActivityPlaceholder(cupertinoTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummaryCard(CupertinoThemeData theme) {
    return FutureBuilder<DailyMealLog?>(
        future: _dailyMealLogFuture,
        builder: (context, snapshot) {
          double currentCalories = 0;
          double protein = 0, carbs = 0, fat = 0;

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            final log = snapshot.data!;
            currentCalories = log.dailyTotalCalories;
            protein = log.dailyTotalProteinGrams;
            carbs = log.dailyTotalCarbGrams;
            fat = log.dailyTotalFatGrams;
          }
          return CupertinoListSection.insetGrouped(
            header: const Text("Today's Nutrition"),
            children: [
              CupertinoListTile(
                title: const Text('Calories'),
                trailing: Text(
                    "${currentCalories.toStringAsFixed(0)} / ${_targetCalories.toStringAsFixed(0)} kcal",
                    style: theme.textTheme.navActionTextStyle
                        .copyWith(color: theme.primaryColor)),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SizedBox(
                  height: 8, // Adjust height for a sleeker look
                  child: LinearProgressIndicator(
                    value: _targetCalories > 0
                        ? (currentCalories / _targetCalories).clamp(0.0, 1.0)
                        : 0,
                    backgroundColor: theme.primaryColor.withAlpha((255 * 0.2).round()),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
              ),
              CupertinoListTile(
                title: const Text('Macros'),
                subtitle: Text(
                    "P ${protein.toStringAsFixed(0)}g, C ${carbs.toStringAsFixed(0)}g, F ${fat.toStringAsFixed(0)}g",
                    style: theme.textTheme.tabLabelTextStyle),
              ),
            ],
          );
        });
  }

  Widget _buildWeeklyProgressRings(CupertinoThemeData theme) {
    return FutureBuilder<Map<String, int>>(
        future: _weeklyStatsFuture,
        builder: (context, snapshot) {
          int workoutsCompleted = 0;
          int activeMinutes = 0;
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            workoutsCompleted = snapshot.data!['workoutsCompleted'] ?? 0;
            activeMinutes = snapshot.data!['activeMinutes'] ?? 0;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: WeeklyProgressRing(
                  title: "Workouts This Week",
                  currentProgress: workoutsCompleted.toDouble(),
                  goal: _targetWeeklyWorkouts.toDouble(),
                  primaryColor: theme.primaryColor,
                  backgroundColor: CupertinoColors.secondarySystemGroupedBackground,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: WeeklyProgressRing(
                  title: "Active Minutes",
                  currentProgress: activeMinutes.toDouble(),
                  goal: _targetWeeklyActiveMinutes.toDouble(),
                  primaryColor: theme.primaryContrastingColor, // Changed for variety
                  backgroundColor: CupertinoColors.secondarySystemGroupedBackground,
                ),
              ),
            ],
          );
        });
  }

  Widget _buildQuickActions(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: const Text("Quick Actions"),
      children: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickActionTile(
                icon: CupertinoIcons.sportscourt,
                label: "Workout",
                onTapRoute: '/workout-plans'),
            QuickActionTile(
                icon: CupertinoIcons.add_circled,
                label: "Log Meal",
                onTapRoute: '/log-meal-quick'),
            QuickActionTile(
                icon: CupertinoIcons.chart_bar_square_fill,
                label: "Progress",
                onTapRoute: '/progress'),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressHighlights(CupertinoThemeData theme) {
    return CupertinoListSection.insetGrouped(
      header: const Text("Progress Highlights"),
      children: [
        FutureBuilder<WeightEntry?>(
            future: _latestWeightFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return CupertinoListTile(
                  leading: Icon(CupertinoIcons.gauge,
                      color: theme.primaryContrastingColor),
                  title: Text(
                      "Current Weight: ${snapshot.data!.weightKg.toStringAsFixed(1)} kg"),
                  subtitle: Text(
                      "Logged on: ${DateFormat.yMd().format(snapshot.data!.date)}"),
                );
              }
              return const CupertinoListTile(title: Text("No weight data yet."));
            }),
        // TODO: Add goal progress summary here if needed
      ],
    );
  }

  Widget _buildAiRecommendationsPlaceholder(CupertinoThemeData theme) {
    return CupertinoListSection.insetGrouped(
      header: const Row(
        children: [
          Icon(CupertinoIcons.wand_stars, size: 20), // Color will be inherited
          SizedBox(width: 8),
          Text("AI Coach Recommendations"),
        ],
      ),
      children: const [
        CupertinoListTile(
          title: Text("Personalized workout tips and meal suggestions coming soon!"),
        ),
      ],
    );
  }

  Widget _buildRecentActivityPlaceholder(CupertinoThemeData theme) {
    return CupertinoListSection.insetGrouped(
      header: const Text("Recent Activity"),
      children: const [
        ActivityFeedItem(
            icon: CupertinoIcons.tuningfork,
            activity: "Completed 'Morning Cardio'",
            time: "20 mins ago"),
        ActivityFeedItem(
            icon: CupertinoIcons.rosette,
            activity: "Unlocked 'Early Bird' Badge",
            time: "1 hour ago"),
      ],
    );
  }
}

// Helper extension for String capitalization
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}

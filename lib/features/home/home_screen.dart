import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/goal.dart';
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/models/weight_entry.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final ThemeData theme = Theme.of(context);
    final userName = _currentUser?.name ?? "User";

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("$_greeting, $userName!", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.bell, color: theme.colorScheme.onSurface),
            onPressed: () => context.go('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            FutureBuilder<WorkoutPlan?>(
              future: _todaysWorkoutPlanFuture,
              builder: (context, snapshot) {
                return HeroWorkoutBanner(workoutPlan: snapshot.data); // Pass plan, can be null
              }
            ),
            const SizedBox(height: 24),
            StreakTrackerWidget(streakCount: _currentUser?.streakCount ?? 0),
            const SizedBox(height: 24),
            _buildNutritionSummaryCard(theme),
            const SizedBox(height: 24),
            _buildWeeklyProgressRings(theme),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildProgressHighlights(theme),
            const SizedBox(height: 24),
            _buildAiRecommendationsPlaceholder(theme),
            const SizedBox(height: 24),
            _buildRecentActivityPlaceholder(theme), // Using placeholder for now
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryCard(ThemeData theme) {
    return FutureBuilder<DailyMealLog?>(
      future: _dailyMealLogFuture,
      builder: (context, snapshot) {
        double currentCalories = 0;
        double protein = 0, carbs = 0, fat = 0;

        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          final log = snapshot.data!;
          currentCalories = log.dailyTotalCalories;
          protein = log.dailyTotalProteinGrams;
          carbs = log.dailyTotalCarbGrams;
          fat = log.dailyTotalFatGrams;
        }
        // Still show card if no data or loading, with 0 values
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Nutrition", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Calories:", style: GoogleFonts.inter(fontSize: 16)),
                    Text("${currentCalories.toStringAsFixed(0)} / ${_targetCalories.toStringAsFixed(0)} kcal", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _targetCalories > 0 ? (currentCalories / _targetCalories).clamp(0.0,1.0) : 0,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
                const SizedBox(height: 12),
                 Text("Macros: P ${protein.toStringAsFixed(0)}g, C ${carbs.toStringAsFixed(0)}g, F ${fat.toStringAsFixed(0)}g", style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildWeeklyProgressRings(ThemeData theme) {
    return FutureBuilder<Map<String, int>>(
      future: _weeklyStatsFuture,
      builder: (context, snapshot) {
        int workoutsCompleted = 0;
        int activeMinutes = 0;
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
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
                primaryColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WeeklyProgressRing(
                title: "Active Minutes",
                currentProgress: activeMinutes.toDouble(),
                goal: _targetWeeklyActiveMinutes.toDouble(),
                primaryColor: theme.colorScheme.tertiary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildQuickActions(BuildContext context) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickActionTile(icon: CupertinoIcons.sportscourt, label: "Workout", onTapRoute: '/workout-plans'), // Updated route
            QuickActionTile(icon: CupertinoIcons.add_circled, label: "Log Meal", onTapRoute: '/log-meal-quick'), // New route for quick log
            QuickActionTile(icon: CupertinoIcons.chart_bar_square_fill, label: "Progress", onTapRoute: '/progress'),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressHighlights(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Progress Highlights", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        FutureBuilder<WeightEntry?>(
          future: _latestWeightFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return Card(
                child: ListTile(
                  leading: Icon(CupertinoIcons.gauge, color: theme.colorScheme.secondary),
                  title: Text("Current Weight: ${snapshot.data!.weightKg.toStringAsFixed(1)} kg", style: GoogleFonts.inter()),
                  subtitle: Text("Logged on: ${DateFormat.yMd().format(snapshot.data!.date)}", style: GoogleFonts.inter()),
                ),
              );
            }
            return const SizedBox.shrink(); // Or a placeholder card
          }
        ),
        // TODO: Add goal progress summary here if needed
      ],
    );
  }

  Widget _buildAiRecommendationsPlaceholder(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.wand_stars, color: theme.colorScheme.tertiary, size: 20),
                const SizedBox(width: 8),
                Text("AI Coach Recommendations", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 10),
            Text("Personalized workout tips and meal suggestions coming soon!", style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityPlaceholder(ThemeData theme) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Activity", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        const Column( // Placeholder items
            children: [
              ActivityFeedItem(icon: CupertinoIcons.tuningfork, activity: "Completed 'Morning Cardio'", time: "20 mins ago"),
              ActivityFeedItem(icon: CupertinoIcons.rosette, activity: "Unlocked 'Early Bird' Badge", time: "1 hour ago"),
            ],
          ),
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

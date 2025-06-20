import 'package:aksumfit/models/daily_meal_log.dart';
// import 'package:aksumfit/models/goal.dart'; // Not used in new structure
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/models/weight_entry.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Changed from Cupertino
import 'package:go_router/go_router.dart';
import 'package:aksumfit/features/home/widgets/streak_tracker_widget.dart';
import 'package:aksumfit/features/home/widgets/muscle_hit_map_card.dart'; // Import for MuscleHitMapCard
// Removed unused old widgets
// import 'package:aksumfit/features/home/widgets/hero_workout_banner.dart';
// import 'package:aksumfit/features/home/widgets/quick_action_tile.dart';
// import 'package:aksumfit/features/home/widgets/weekly_progress_ring.dart';
// import 'package:aksumfit/widgets/activity_feed_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aksumfit/features/nutrition/presentation/screens/camera_screen.dart'; // Import CameraScreen

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
  // Future<Map<String, int>>? _weeklyStatsFuture; // Not used in new card structure
  Future<WeightEntry?>? _latestWeightFuture;
  // Future<List<Goal>>? _activeGoalsFuture; // Not used in new card structure

  // Example target values (would ideally come from user settings or goals)
  final double _targetCalories = 2500;
  // final int _targetWeeklyWorkouts = 5; // Not used in new card structure
  // final int _targetWeeklyActiveMinutes = 200; // Not used in new card structure


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
        // _weeklyStatsFuture = ApiService().getWeeklyWorkoutStats(userId);
        _latestWeightFuture = ApiService().getLatestWeightEntry(userId);
        // _activeGoalsFuture = ApiService().getGoals(userId, isActive: true);
      });
    }
  }

  Future<void> _refreshData() async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    // Ensure _currentUser is updated if it can change.
    if (mounted) {
      setState(() {
        _currentUser = authManager.currentUser;
        _greeting = _getGreeting(); // Re-calculate greeting if user name might change or for time of day
      });
    }

    if (_currentUser != null) {
      final userId = _currentUser!.id;
      if (mounted) {
        setState(() {
          _todaysWorkoutPlanFuture = ApiService().getTodaysWorkoutPlan(userId);
          _dailyMealLogFuture = ApiService().getDailyMealLog(userId, DateTime.now());
          // _weeklyStatsFuture = ApiService().getWeeklyWorkoutStats(userId);
          _latestWeightFuture = ApiService().getLatestWeightEntry(userId);
          // _activeGoalsFuture = ApiService().getGoals(userId, isActive: true);
        });
      }
    }
    // Added a small delay to simulate network activity for refresh indicator
    return Future.delayed(const Duration(milliseconds: 500));
  }


  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = _currentUser?.name.split(' ').first ?? "User"; // Get first name

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('$_greeting, $userName!', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.flame_fill, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () => context.go('/streak-details'),
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () => context.go('/notifications'),
          ),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // StreakTrackerWidget can be placed here if desired, or integrated into a card
            if (_currentUser?.streakCount != null && _currentUser!.streakCount > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: StreakTrackerWidget(streakCount: _currentUser!.streakCount),
              ),
              const SizedBox(height: 16),
            ],
            FutureBuilder<WorkoutPlan?>(
              future: _todaysWorkoutPlanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                  return _buildPlaceholderCard("Loading Today's Workout...");
                }
                return _buildTodaysWorkoutCard(snapshot.data);
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<DailyMealLog?>(
              future: _dailyMealLogFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                  return _buildPlaceholderCard("Loading Nutrition Log...");
                }
                return _buildMealTrackerCard(snapshot.data);
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<WeightEntry?>(
              future: _latestWeightFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                  return _buildPlaceholderCard("Loading Progress...");
                }
                return _buildProgressChartCard(snapshot.data);
              },
            ),
            const SizedBox(height: 16),
            const MuscleHitMapCard(), // Added MuscleHitMapCard
            const SizedBox(height: 16),
            _buildChallengesCard(),
            const SizedBox(height: 16),
            // _buildAiRecommendationsPlaceholder(theme), // Optional: Can be added back if desired
            // const SizedBox(height: 16),
            // _buildRecentActivityPlaceholder(theme), // Optional: Can be added back if desired
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(String message) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2, // Dark slate for dialogs
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 150, // Example height
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(), // Already const
              const SizedBox(height: 10), // Already const
              Text(message, style: theme.textTheme.titleMedium), // Cannot be const: message is dynamic, style is from theme
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysWorkoutCard(WorkoutPlan? plan) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Workout", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Theme-dependent style
            const SizedBox(height: 12), // Const
            if (plan != null) ...[
              Text(plan.name, style: theme.textTheme.titleMedium), // Dynamic text, theme-dependent style
              const SizedBox(height: 8), // Const
              Text(plan.description ?? 'No description available.', style: theme.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis), // Dynamic text, theme-dependent style
              const SizedBox(height: 16), // Const
              // Example progress, replace with actual logic if available
              if(plan.estimatedDurationMinutes != null && plan.estimatedDurationMinutes! > 0) ...[
                LinearProgressIndicator( // Cannot be const due to theme colors and dynamic value (though value is placeholder here)
                  value: 0.3,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8), // Const
                Text("3 of ${plan.exercises.length ?? 10} exercises completed", style: theme.textTheme.bodySmall), // Dynamic text, theme-dependent style
                const SizedBox(height: 16), // Const
              ],
              ElevatedButton( // Cannot be const due to onPressed and style from theme
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 40) // Size can be const
                ),
                onPressed: () {
                  if (plan.id.isNotEmpty) {
                    context.go('/workout-plans/${plan.id}');
                  }
                },
                child: const Text("Start Workout"), // Const
              ),
            ] else ...[
              Text("No workout scheduled for today. Rest up or pick one from your plans!", style: theme.textTheme.bodyMedium), // Theme-dependent style
              const SizedBox(height: 16), // Const
              ElevatedButton( // Cannot be const due to onPressed and style from theme
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    minimumSize: const Size(double.infinity, 40) // Size can be const
                ),
                onPressed: () => context.go('/browse-workouts'),
                child: const Text("Browse Workouts"), // Const
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealTrackerCard(DailyMealLog? mealLog) {
    final theme = Theme.of(context);
    final currentCalories = mealLog?.dailyTotalCalories ?? 0;
    final progress = _targetCalories > 0 ? (currentCalories / _targetCalories).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Meal Tracker", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Theme-dependent style
            const SizedBox(height: 12), // Const
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${currentCalories.toStringAsFixed(0)} / ${_targetCalories.toStringAsFixed(0)} kcal", style: theme.textTheme.titleMedium), // Dynamic text, theme-dependent style
                OutlinedButton.icon( // Cannot be const due to onPressed and style from theme
                  icon: const Icon(Icons.camera_alt_outlined), // Const
                  label: const Text("Snap Meal"), // Const
                  onPressed: () async {
                    final imagePath = await Navigator.of(context).push<String>(
                      MaterialPageRoute(builder: (context) => const CameraScreen()), // CameraScreen can be const
                    );
                    if (imagePath != null && imagePath.isNotEmpty && context.mounted) {
                      print('Captured image path: $imagePath');
                      context.go('/log-meal-quick', extra: <String, dynamic>{'imagePath': imagePath});
                    }
                  },
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Const
            LinearProgressIndicator( // Cannot be const due to theme colors and dynamic value
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.tertiary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12), // Const
            Text( // Dynamic text, theme-dependent style
                "Macros: P:${mealLog?.dailyTotalProteinGrams.toStringAsFixed(0) ?? 0}g  C:${mealLog?.dailyTotalCarbGrams.toStringAsFixed(0) ?? 0}g  F:${mealLog?.dailyTotalFatGrams.toStringAsFixed(0) ?? 0}g",
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8), // Const
            TextButton(onPressed: () => context.go('/nutrition'), child: const Text("View Full Nutrition Details")) // Child Text can be const
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChartCard(WeightEntry? latestWeight) {
    final theme = Theme.of(context);

    // Mock data for progress highlights
    const int workoutsThisWeek = 3;
    const int plannedWorkouts = 5;
    const int totalActiveMinutes = 120;
    const String personalRecordImprovement = "New Squat PR: 100kg (+5kg)";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Progress Highlights", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Theme-dependent style
            const SizedBox(height: 16), // Const

            // Row for key stats to potentially make it more compact
            Row( // Cannot be const because children are not const
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column( // Cannot be const because children are not const
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Workouts This Week:", style: theme.textTheme.titleMedium), // Theme-dependent style
                    Text("$workoutsThisWeek / $plannedWorkouts sessions", style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)), // Dynamic text, theme-dependent style
                    const SizedBox(height: 12), // Const
                    Text("Total Active Minutes:", style: theme.textTheme.titleMedium), // Theme-dependent style
                    Text("$totalActiveMinutes mins", style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)), // Dynamic text, theme-dependent style
                  ],
                ),
                // Keeping the chart icon, perhaps smaller or integrated differently if needed
                Container( // Cannot be const due to BoxDecoration and Icon color from theme
                  padding: const EdgeInsets.all(8), // EdgeInsets can be const
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.show_chart_rounded, size: 36, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
                ),
              ],
            ),

            const SizedBox(height: 16), // Const
            const Divider(), // Const
            const SizedBox(height: 12), // Const

            Text("Recent Achievements:", style: theme.textTheme.titleMedium), // Theme-dependent style
            const SizedBox(height: 4), // Const
            Text(personalRecordImprovement, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)), // Dynamic text, theme-dependent style

            const SizedBox(height: 16), // Const

            if (latestWeight != null) ...[
              Text("Latest Weight: ${latestWeight.weightKg.toStringAsFixed(1)} kg (Logged: ${DateFormat.yMd().format(latestWeight.date)})", style: theme.textTheme.bodyMedium), // Dynamic text, theme-dependent style
              const SizedBox(height: 4), // Const
            ] else ...[
              Text("No weight logged yet. Start tracking your progress!", style: theme.textTheme.bodyMedium), // Theme-dependent style
              const SizedBox(height: 4), // Const
            ],
            const SizedBox(height: 8), // Const
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => context.go('/progress'), child: const Text("View Detailed Progress")), // Child Text can be const
            )

          ],
        ),
      ),
    );
  }

  Widget _buildChallengesCard() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Challenges & Community", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Theme-dependent style
            const SizedBox(height: 12), // Const
            ListTile( // Cannot be const due to onTap and dynamic elements + theme colors
              contentPadding: EdgeInsets.zero, // EdgeInsets can be const
              leading: Icon(Icons.emoji_events_outlined, color: theme.colorScheme.secondary),
              title: const Text("Summer Shred Challenge"), // Const
              subtitle: const Text("Ends in 12 days - 87 participants"), // Const
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16), // Const
              onTap: () { /* TODO: Navigate to challenge details */ },
            ),
            const Divider(), // Const
            ListTile( // Cannot be const due to onTap and dynamic elements + theme colors
              contentPadding: EdgeInsets.zero, // EdgeInsets can be const
              leading: Icon(Icons.groups_outlined, color: theme.colorScheme.tertiary),
              title: const Text("Local Running Group"), // Const
              subtitle: const Text("New post: 'Saturday Morning Run Route'"), // Const
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16), // Const
              onTap: () { /* TODO: Navigate to group details */ },
            ),
            const SizedBox(height: 8), // Const
            TextButton(onPressed: () => context.go('/social'), child: const Text("Explore More")) // Child Text can be const
          ],
        ),
      ),
    );
  }
}

// Helper extension for String capitalization (already present, can be removed if not used elsewhere or moved to a common place)
// extension StringExtension on String {
//   String capitalize() {
//     if (this.isEmpty) return this;
//     return this[0].toUpperCase() + this.substring(1);
//   }
// }

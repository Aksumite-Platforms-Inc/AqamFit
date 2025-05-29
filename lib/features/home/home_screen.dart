import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added for context.go
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/home/widgets/streak_tracker_widget.dart';
import 'package:aksumfit/features/home/widgets/hero_workout_banner.dart';
import 'package:aksumfit/features/home/widgets/quick_action_tile.dart';
import 'package:aksumfit/features/home/widgets/weekly_progress_ring.dart';
import 'package:aksumfit/widgets/activity_feed_item.dart'; // Import for ActivityFeedItem

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get theme
    final String greeting = _getGreeting(); // Get time-based greeting
    const String userName = "User"; // Placeholder for username

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Use theme background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "$greeting, $userName!", // Personalized greeting
          style: GoogleFonts.inter(
            fontSize: 22, // Slightly adjusted for longer text
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onBackground, // Use theme color
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onBackground), // Use theme color
            onPressed: () {
              context.go('/notifications'); // Navigate to notifications
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const HeroWorkoutBanner(), // Moved HeroWorkoutBanner to the top
          const SizedBox(height: 24),
          const StreakTrackerWidget(), // Moved StreakTrackerWidget after HeroWorkoutBanner
          const SizedBox(height: 24),
          // Weekly Progress Rings Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: WeeklyProgressRing(
                  title: "Workouts This Week",
                  currentProgress: 3,
                  goal: 5,
                  primaryColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surfaceVariant, // Using a variant for background
                ),
              ),
              const SizedBox(width: 16), // Spacing between rings
              Expanded(
                child: WeeklyProgressRing(
                  title: "Active Minutes",
                  currentProgress: 210,
                  goal: 300,
                  primaryColor: theme.colorScheme.tertiary, // Using tertiary for variety
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activity Section
          Text( // Changed Padding to SizedBox before title
            "Recent Activity",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12), // Consistent spacing after title
          const Column(
            children: [
              ActivityFeedItem(
                icon: Icons.directions_run_rounded,
                activity: "Completed 'Morning Cardio'",
                time: "20 mins ago",
              ),
              ActivityFeedItem(
                icon: Icons.emoji_events_rounded,
                activity: "Unlocked 'Early Bird' Badge",
                time: "1 hour ago",
              ),
              ActivityFeedItem(
                icon: Icons.fitness_center_rounded,
                activity: "Logged 'Strength Session'",
                time: "Yesterday",
              ),
            ],
          ),
          const SizedBox(height: 24), // Consistent spacing after Recent Activity items
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Actions",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const QuickActionTile(
                    icon: Icons.fitness_center,
                    label: "Start Workout",
                    onTapRoute: '/workout', // Added route
                  ),
                  const QuickActionTile(
                    icon: Icons.restaurant_menu,
                    label: "Log Meal",
                    onTapRoute: '/log-meal', // Added route
                  ),
                  const QuickActionTile(
                    icon: Icons.bar_chart_rounded,
                    label: "View Progress",
                    onTapRoute: '/progress', // Added route
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

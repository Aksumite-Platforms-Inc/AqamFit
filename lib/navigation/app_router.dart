import 'package:flutter/cupertino.dart'; // Added for CupertinoPage
import 'package:flutter/material.dart'; // For Widget type, if needed, and for context
import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../core/presentation/main_scaffold.dart';
import '../features/notifications/notification_screen.dart';
import '../features/nutrition/presentation/screens/log_meal_screen.dart';
import '../features/workout/workout_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/explore/presentation/screens/exercise_library_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../features/social/presentation/screens/social_screen.dart';
import '../features/workout/presentation/screens/workout_summary_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart'; // Import SettingsScreen

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/main',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const MainScaffold(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const NotificationScreen(),
      ),
    ),
    GoRoute(
      path: '/log-meal',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const LogMealScreen(),
      ),
    ),
    GoRoute(
      path: '/workout',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const WorkoutScreen(),
      ),
    ),
    GoRoute(
      path: '/progress',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const ProgressScreen(),
      ),
    ),
    GoRoute(
      path: '/exercise-library',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const ExerciseLibraryScreen(),
      ),
    ),
    GoRoute(
      path: '/nutrition',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const NutritionScreen(),
      ),
    ),
    GoRoute(
      path: '/social',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const SocialScreen(),
      ),
    ),
    GoRoute(
      path: '/workout-summary',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const WorkoutSummaryScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
  ],
);

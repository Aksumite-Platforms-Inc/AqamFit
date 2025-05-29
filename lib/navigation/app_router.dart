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
import '../features/nutrition/presentation/screens/nutrition_screen.dart'; // Import NutritionScreen
import '../features/social/presentation/screens/social_screen.dart'; // Import SocialScreen

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScaffold(), // Updated builder
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/log-meal',
      builder: (context, state) => const LogMealScreen(),
    ),
    GoRoute(
      path: '/workout',
      builder: (context, state) => const WorkoutScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/exercise-library',
      builder: (context, state) => const ExerciseLibraryScreen(),
    ),
    GoRoute(
      path: '/nutrition',
      builder: (context, state) => const NutritionScreen(),
    ),
    GoRoute(
      path: '/social',
      builder: (context, state) => const SocialScreen(),
    ),
  ],
);

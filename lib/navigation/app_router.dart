import 'package:flutter/material.dart'; // For Widget type, if needed, and for context
import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../core/presentation/main_scaffold.dart';
import '../features/notifications/notification_screen.dart';
import '../features/nutrition/presentation/screens/log_meal_screen.dart'; // Import for LogMealScreen
import '../features/workout/workout_screen.dart'; // Import for WorkoutScreen
import '../features/progress/progress_screen.dart'; // Import for ProgressScreen

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
  ],
);
